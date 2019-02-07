module Spree
  class Gateway::MollieGateway < PaymentMethod
    include ::Spree::Mollie::MoneyFormatter

    preference :api_key, :string
    preference :hostname, :string
    # When set to true, Mollie will automatically charge all discounts and shipping
    # fees after the first shipment.
    preference :collect_shipping_costs_and_discounts_on_first_shipment, :boolean, default: true

    has_many :spree_mollie_payment_sources, class_name: 'Spree::MolliePaymentSource'

    # Only enable one-click payments if spree_auth_devise is installed
    def self.allow_one_click_payments?
      Gem.loaded_specs.key?('spree_auth_devise')
    end

    def payment_source_class
      Spree::MolliePaymentSource
    end

    def actions
      %w[credit]
    end

    def provider_class
      ::Mollie::Client
    end

    # Always create a source which references to the selected Mollie payment method.
    def source_required?
      true
    end

    def available_for_order?(_order)
      true
    end

    def auto_capture?
      true
    end

    def gateways(options = {})
      payment_method = Spree::PaymentMethod.find_by_type self.class
      if options[:order].present? && options[:order].is_a?(Spree::Order)
        payment_method.available_methods_for_order(options[:order])
      elsif options[:amount].present?
        payment_method.available_methods(options)
      else
        raise 'Unprocessable input'
      end.map(&:attributes)
    end

    # Create Mollie order
    def process(money, source, gateway_options)
      MollieLogger.debug("About to create payment for order #{gateway_options[:order_id]}")

      begin
        # First of all, invalidate all previous Mollie orders to prevent multiple paid orders
        invalidate_previous_orders(gateway_options[:order].id)

        # Create a new Mollie order and update the payment source
        order_params = prepare_order_params(money, source, gateway_options)
        mollie_order = ::Mollie::Order.create(order_params)
        MollieLogger.debug("Mollie order #{mollie_order.id} created for Spree order #{gateway_options[:order_id]}")

        source.status = mollie_order.status
        source.payment_id = mollie_order.id
        source.payment_url = mollie_order.checkout_url
        source.save!
        ActiveMerchant::Billing::Response.new(true, 'Order created')
      rescue ::Mollie::Exception => e
        MollieLogger.debug("Could not create payment for order #{gateway_options[:order_id]}: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, "Order could not be created: #{e.message}")
      end
    end

    # Create a Mollie customer which can be passed with a payment.
    # Required for one-click Mollie payments.
    def create_customer(user)
      customer = ::Mollie::Customer.create(
        email: user.email,
        api_key: get_preference(:api_key)
      )
      MollieLogger.debug("Created a Mollie Customer for Spree user with ID #{customer.id}")
      customer
    end

    # # Create a new Mollie refund
    # def credit(_credit_cents, _payment_id, _options)
    #   ActiveMerchant::Billing::Response.new(false, 'Refunding Mollie orders is not yet supported in Spree. Please refund your order via Mollie Dashboard')
    # end

    # Create a new Mollie refund
    def credit(credit_cents, payment_id, options)
      order = options[:originator].try(:payment).try(:order)
      order_number = order.try(:number)
      order_currency = order.try(:currency)
      MollieLogger.debug("Starting refund for order #{order_number}")

      begin
        ::Mollie::Payment::Refund.create(
            payment_id: payment_id,
            amount: {
                value: format_money(::Spree::Money.new(credit_cents/100.0).money),
                currency: order_currency
            },
            description: "Refund Spree Order ID: #{order_number}",
            api_key: get_preference(:api_key)
        )
        MollieLogger.debug("Successfully refunded #{order.display_total} for order #{order_number}")
        ActiveMerchant::Billing::Response.new(true, 'Refund successful')
      rescue ::Mollie::Exception => e
        MollieLogger.debug("Refund failed for order #{order_number}: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, 'Refund unsuccessful')
      end
    end

    def authorize(*_args)
      ActiveMerchant::Billing::Response.new(true, 'Mollie will automatically capture the amount after creating a shipment.')
    end

    def capture(*_args)
      ActiveMerchant::Billing::Response.new(true, 'Mollie will automatically capture the amount after creating a shipment.')
    end

    def cancel(mollie_order_id)
      MollieLogger.debug("Starting cancellation for #{mollie_order_id}")

      begin
        mollie_order = ::Mollie::Order.get(
          mollie_order_id,
          api_key: get_preference(:api_key)
        )
        if mollie_order.cancelable?
          cancel_order!(mollie_order_id)
          ActiveMerchant::Billing::Response.new(true, 'Mollie order has been cancelled.')
        else
          MollieLogger.debug("Spree order #{mollie_order_id} has been canceled, could not cancel Mollie order.")
          ActiveMerchant::Billing::Response.new(true, 'Spree order has been canceled, could not cancel Mollie order.')
        end
      rescue ::Mollie::Exception => e
        MollieLogger.debug("Order #{mollie_order_id} could not be canceled: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, 'Order cancellation unsuccessful.')
      end
    end

    def available_methods(params = nil)
      method_params = {
        api_key: get_preference(:api_key),
        include: 'issuers',
        resource: 'orders'
      }

      method_params.merge! params if params.present?

      ::Mollie::Method.all(method_params)
    end

    def available_methods_for_order(order)
      params = {
        amount: {
          currency: order.currency,
          value: format_money(order.display_total.money)
        },
        resource: 'orders',
        billingCountry: order.billing_address.country.try(:iso)
      }
      available_methods(params)
    end

    def update_payment_status(spree_payment)
      mollie_order_id = spree_payment.source.payment_id
      mollie_order = ::Mollie::Order.get(
        mollie_order_id,
        embed: 'payments',
        api_key: get_preference(:api_key)
      )

      MollieLogger.debug("Checking Mollie order status for order #{mollie_order_id}. Its status is: #{mollie_order.status}")
      update_by_mollie_status!(mollie_order, spree_payment)
    end

    def update_by_mollie_status!(mollie_order, spree_payment)
      Spree::Mollie::PaymentStateUpdater.update(mollie_order, spree_payment)
    end

    private

    def prepare_order_params(money, source, gateway_options)
      gateway_preferences = {
        hostname: get_preference(:hostname),
        api_key: get_preference(:api_key)
      }
      Spree::Mollie::OrderSerializer.serialize(money, source, gateway_options, gateway_preferences)
    end

    def cancel_order!(mollie_order_id)
      ::Mollie::Order.cancel(
        mollie_order_id,
        api_key: get_preference(:api_key)
      )
      MollieLogger.debug("Canceled Mollie order #{mollie_order_id}")
    end

    def invalidate_previous_orders(spree_order_id)
      Spree::Payment.where(order_id: spree_order_id, state: 'processing').each do |payment|
        begin
          mollie_order_id = payment.source.payment_id
          order = ::Mollie::Order.get(
            mollie_order_id,
            api_key: get_preference(:api_key)
          )
          cancel_order!(mollie_order_id) if order.cancelable?
        rescue ::Mollie::Exception => e
          MollieLogger.debug("Failed to invalidate previous order: #{e.message}")
        end
      end
    end
  end
end
