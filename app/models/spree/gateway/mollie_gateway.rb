module Spree
  class Gateway::MollieGateway < PaymentMethod
    preference :api_key, :string
    preference :hostname, :string

    has_many :spree_mollie_payment_sources, class_name: 'Spree::MolliePaymentSource'

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

    # Create a new Mollie payment.
    def create_transaction(money_in_cents, source, gateway_options)
      MollieLogger.debug("About to create payment for order #{gateway_options[:order_id]}")

      begin
        mollie_payment = ::Mollie::Payment.create(
            prepare_payment_params(money_in_cents, source, gateway_options)
        )
        MollieLogger.debug("Payment #{mollie_payment.id} created for order #{gateway_options[:order_id]}")

        source.status = mollie_payment.status
        source.payment_id = mollie_payment.id
        source.payment_url = mollie_payment.payment_url
        source.save!
        ActiveMerchant::Billing::Response.new(true, 'Payment created')
      rescue Mollie::Exception => e
        MollieLogger.debug("Could not create payment for order #{gateway_options[:order_id]}: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, 'Payment could not be created')
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

      source.issuer.present?
      order_params.merge! ({
        issuer: source.issuer
      })

      if customer_id.present?
        if source.payment_method_name.match(Regexp.union([::Mollie::Method::BITCOIN, ::Mollie::Method::BANKTRANSFER, ::Mollie::Method::GIFTCARD]))
          order_params.merge! ({
              billingEmail: gateway_options[:email]
          })
        end

        mollie_customer_id = Spree::User.find(customer_id).mollie_customer_id

        # Allow one-click payments by passing Mollie customer ID.
        if mollie_customer_id.present?
          order_params.merge! ({
              customerId: customer_id
          })
        end
      end

      order_params
    end

    # Create a new Mollie refund
    def credit(credit_cents, payment_id, options)
      order_number = options[:originator].try(:payment).try(:order).try(:number)
      MollieLogger.debug("Starting refund for order #{order_number}")

      begin
        amount = credit_cents / 100.0
        refund = Mollie::Payment::Refund.create(
            payment_id: payment_id,
            amount: amount,
            description: "Refund Spree Order ID: #{order_number}",
            api_key: get_preference(:api_key)
        )
        MollieLogger.debug("Successfully refunded #{amount} for order #{order_number}")
        ActiveMerchant::Billing::Response.new(true, 'Refund successful')
      rescue Mollie::Exception => e
        MollieLogger.debug("Refund failed for order #{order_number}: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, 'Refund unsuccessful')
      end
    end

    def available_payment_methods
      ::Mollie::Method.all(
          api_key: get_preference(:api_key),
          include: 'issuers'
      )
    end

    def update_payment_status(payment)
      mollie_transaction_id = payment.source.payment_id
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
          MollieLogger.debug('Unhandled Mollie payment state received. Therefore we did not update the payment state.')
      end

      payment.source.update(status: payment.state)
    end
  end
end
