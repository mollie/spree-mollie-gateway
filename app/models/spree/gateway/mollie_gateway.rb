module Spree
  class Gateway::MollieGateway < PaymentMethod
    preference :api_key, :string
    preference :hostname, :string

    has_many :spree_mollie_payment_sources, class_name: 'Spree::MolliePaymentSource'

    # Only enable one-click payments if spree_auth_devise is installed
    def self.allow_one_click_payments?
      Gem.loaded_specs.has_key?('spree_auth_devise')
    end

    def payment_source_class
      Spree::MolliePaymentSource
    end

    def actions
      %w{credit}
    end

    def provider_class
      ::Mollie::Client
    end

    # Always create a source which references to the selected Mollie payment method.
    def source_required?
      true
    end

    def available_for_order?(order)
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
      end.map do |method|
        method.attributes
      end
    end

    # Create a new Mollie payment.
    def create_transaction(money, source, gateway_options)
      MollieLogger.debug("About to create payment for order #{gateway_options[:order_id]}")

      begin
        mollie_payment = ::Mollie::Payment.create(
            prepare_payment_params(money, source, gateway_options)
        )
        MollieLogger.debug("Payment #{mollie_payment.id} created for order #{gateway_options[:order_id]}")

        source.status = mollie_payment.status
        source.payment_id = mollie_payment.id
        source.payment_url = mollie_payment.checkout_url
        source.save!
        ActiveMerchant::Billing::Response.new(true, 'Payment created')
      rescue Mollie::Exception => e
        MollieLogger.debug("Could not create payment for order #{gateway_options[:order_id]}: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, "Payment could not be created: #{e.message}")
      end
    end

    # Create a Mollie customer which can be passed with a payment.
    # Required for one-click Mollie payments.
    def create_customer(user)
      customer = Mollie::Customer.create(
          email: user.email,
          api_key: get_preference(:api_key),
          )
      MollieLogger.debug("Created a Mollie Customer for Spree user with ID #{customer.id}")
      customer
    end

    def prepare_payment_params(money, source, gateway_options)
      spree_routes = ::Spree::Core::Engine.routes.url_helpers
      order_number = gateway_options[:order_id]
      customer_id = gateway_options[:customer_id]
      currency = gateway_options[:currency]

      order_params = {
          amount: {
              value: format_money(money),
              currency: currency
          },
          description: "Spree Order: #{order_number}",
          redirectUrl: spree_routes.mollie_validate_payment_mollie_url(
              order_number: order_number,
              host: get_preference(:hostname)
          ),
          webhookUrl: spree_routes.mollie_update_payment_status_mollie_url(
              order_number: order_number,
              host: get_preference(:hostname)
          ),
          metadata: {
              order_id: order_number
          },
          api_key: get_preference(:api_key),
      }

      if source.try(:payment_method_name).present?
        order_params.merge! ({
            method: source.payment_method_name,
        })
      end

      if source.try(:issuer).present?
        order_params.merge! ({
            issuer: source.issuer
        })
      end

      if customer_id.present?
        if source.try(:payment_method_name).present?
          if source.payment_method_name.match(Regexp.union([::Mollie::Method::BITCOIN, ::Mollie::Method::BANKTRANSFER, ::Mollie::Method::GIFTCARD]))
            order_params.merge! ({
                billingEmail: gateway_options[:email]
            })
          end
        end

        if Spree::Gateway::MollieGateway.allow_one_click_payments?
          mollie_customer_id = Spree.user_class.find(customer_id).try(:mollie_customer_id)

          # Allow one-click payments by passing Mollie customer ID.
          if mollie_customer_id.present?
            order_params.merge! ({
                customerId: mollie_customer_id
            })
          end
        end
      end

      order_params
    end

    # Create a new Mollie refund
    def credit(credit_cents, payment_id, options)
      order = options[:originator].try(:payment).try(:order)
      order_number = order.try(:number)
      order_currency = order.try(:currency)
      MollieLogger.debug("Starting refund for order #{order_number}")

      begin
        Mollie::Payment::Refund.create(
            payment_id: payment_id,
            amount: {
                value: format_money(order.display_total.money),
                currency: order_currency
            },
            description: "Refund Spree Order ID: #{order_number}",
            api_key: get_preference(:api_key)
        )
        MollieLogger.debug("Successfully refunded #{order.display_total} for order #{order_number}")
        ActiveMerchant::Billing::Response.new(true, 'Refund successful')
      rescue Mollie::Exception => e
        MollieLogger.debug("Refund failed for order #{order_number}: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, 'Refund unsuccessful')
      end
    end

    def cancel(transaction_id)
      begin
        mollie_payment = ::Mollie::Payment.get(
            transaction_id,
            api_key: get_preference(:api_key)
        )
        mollie_payment.delete(transaction_id) if mollie_payment.cancelable?
        ActiveMerchant::Billing::Response.new(true, 'Payment canceled successful')
      rescue Mollie::Exception => e
        MollieLogger.debug("Payment could not be canceled #{transaction_id}: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, 'Payment cancellation unsuccessful')
      end
    end

    def available_methods(params = nil)
      method_params = {
          api_key: get_preference(:api_key),
          include: 'issuers',
      }

      if params.present?
        method_params.merge! params
      end

      ::Mollie::Method.all(method_params)
    end

    def format_money(money)
      money.format(symbol: nil, thousands_separator: nil, decimal_mark: '.')
    end

    def available_methods_for_order(order)
      params = {
          amount: {
              currency: order.currency,
              value: format_money(order.display_total.money)
          }
      }
      available_methods(params)
    end

    def update_payment_status(payment)
      mollie_transaction_id = payment.source.payment_id
      mollie_payment = ::Mollie::Payment.get(
          mollie_transaction_id,
          api_key: get_preference(:api_key)
      )

      MollieLogger.debug("Updating order state for payment. Payment has state #{mollie_payment.status}")

      update_by_mollie_status!(mollie_payment, payment)
    end

    def update_by_mollie_status!(mollie_payment, payment)
      case mollie_payment.status
        when 'paid'
          payment.complete! unless payment.completed?
          payment.order.finalize!
          payment.order.update_attributes(:state => 'complete', :completed_at => Time.now)
        when 'canceled', 'expired', 'failed'
          payment.failure! unless payment.failed?
          payment.order.update_attributes(:state => 'payment', :completed_at => nil)
        else
          MollieLogger.debug('Unhandled Mollie payment state received. Therefore we did not update the payment state.')
          payment.order.update_attributes(state: 'payment', completed_at: nil)
      end

      payment.source.update(status: payment.state)
    end
  end
end
