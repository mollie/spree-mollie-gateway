module Spree
  class Gateway::MollieGateway < Gateway
    preference :api_key, :string
    preference :hostname, :string

    has_many :spree_mollie_payment_sources, class_name: 'Spree::MolliePaymentSource'

    def payment_source_class
      Spree::MolliePaymentSource
    end

    def actions
      %w{authorize purchase capture credit}
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

    def credit(amount, source, gateway_options)
      create_transaction amount, source, gateway_options
    end

    # Create a new Mollie payment.
    def create_transaction(money_in_cents, source, gateway_options)
      MollieLogger.debug("Create payment for order #{gateway_options[:order_id]}")

      mollie_payment = ::Mollie::Payment.create(
        prepare_payment_params(money_in_cents, source, gateway_options)
      )

      MollieLogger.debug("Payment #{mollie_payment.id} created for order #{gateway_options[:order_id]}")

      # payment.response_code = mollie_payment.id
      # payment.save!

      puts "#" * 100
      puts mollie_payment

      source.status = mollie_payment.status
      source.payment_id = mollie_payment.id
      source.payment_url = mollie_payment.payment_url
      source.save!

      ActiveMerchant::Billing::Response.new(true, 'Transaction created')
    end

    # Create a Mollie customer which can be passed with a transaction.
    # Required for one-click Mollie payments.
    def create_customer(user)
      customer = Mollie::Customer.create(
          email: user.email,
          api_key: get_preference(:api_key),
          )
      MollieLogger.debug("Created a Mollie Customer for Spree user with ID #{customer.id}")
      customer
    end

    def prepare_payment_params(money_in_cents, source, gateway_options)
      spree_routes = ::Spree::Core::Engine.routes.url_helpers
      order_number = gateway_options[:order_id]
      customer_id = gateway_options[:customer_id]
      amount = money_in_cents / 100.0

      order_params = {
          amount: amount,
          description: "Spree Order ID: #{order_number}",
          redirectUrl: spree_routes.mollie_validate_payment_mollie_url(
              order_number: order_number,
              host: get_preference(:hostname)
          ),
          webhookUrl: spree_routes.mollie_update_payment_status_mollie_url(
              order_number: order_number,
              host: get_preference(:hostname)
          ),
          method: source.payment_method_name,
          metadata: {
              order_id: order_number
          },
          api_key: get_preference(:api_key),
      }

      if customer_id.present?
        if source.payment_method_name.match(Regexp.union([::Mollie::Method::BITCOIN, ::Mollie::Method::BANKTRANSFER, ::Mollie::Method::GIFTCARD]))
          order_params.merge! ({
              billingEmail: gateway_options[:email]
          })
        end

        # Allow one-click payments by passing Mollie customer ID.
        # if customer_id.present?
        #   order_params.merge! ({
        #       customerId: customer_id
        #   })
        # end
      end

      order_params
    end

    def available_payment_methods
      ::Mollie::Method.all(
          api_key: get_preference(:api_key),
          include: 'issuers'
      )
    end

    def update_payment_status(payment)
      mollie_transaction_id = payment.response_code
      transaction = ::Mollie::Payment.get(
          mollie_transaction_id,
          api_key: get_preference(:api_key)
      )

      MollieLogger.debug("Updating order state for payment. Payment has state #{transaction.status}")

      case transaction.status
        when 'paid'
          payment.complete! unless payment.completed?
          payment.order.finalize!
          payment.order.update_attributes(:state => 'complete', :completed_at => Time.now)
        when 'cancelled', 'expired', 'failed'
          payment.failure! unless payment.failed?
        when 'refunded'
          payment.void! unless payment.void?
        else
          MollieLogger.debug("Unhandled Mollie payment state received. Therefore we did not update the payment state.")
      end

      payment.source.update(status: payment.state)
    end

    private

    def invalidate_prev_transactions(current_payment_id)
      # Cancel all previous payment which are pending or are still being processed
      payments.with_state('processing').or(payments.with_state('pending')).where.not(id: current_payment_id).each do |payment|
        # Set internal payment state to failed
        payment.failure! unless payment.store_credit?
        MollieLogger.debug("Invalidating previous payment: #{payment.number}") unless payment.store_credit?
      end
    end
  end
end
