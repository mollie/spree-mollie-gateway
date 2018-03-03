module Spree
  class Gateway::MollieGateway < PaymentMethod
    preference :api_key, :string
    preference :hostname, :string

    has_many :spree_mollie_transactions, class_name: 'Spree::MollieTransaction'

    def payment_source_class
      Spree::MollieTransaction
    end

    def provider_class
      ::Mollie::Provider
    end

    def source_required?
      true
    end

    def available_for_order?(order)
      true
    end

    # Create a new transaction
    def create_transaction(money, source, gateway_options)
      payment = payments.last

      MollieLogger.debug("Create payment for order #{payment.order.number}")

      transaction = ::Mollie::Payment.create(
          prepare_transaction_params(payment.order, source)
      )

      MollieLogger.debug("Payment #{payment.order.number} created for order #{payment.order.number}")

      invalidate_prev_transactions(payment.id)

      payment.response_code = transaction.id
      payment.save!

      source.payment_id = transaction.id
      source.payment_url = transaction.payment_url
      source.save!

      ActiveMerchant::Billing::Response.new(true, 'Transaction created')
    end

    def create_customer(user)
      customer = Mollie::Customer.create(
          email: user.email,
          api_key: get_preference(:api_key),
          )
      MollieLogger.debug("Created a Mollie Customer for Spree user with ID #{customer.id}")
      customer
    end

    def prepare_transaction_params(order, source)
      spree_routes = ::Spree::Core::Engine.routes.url_helpers
      order_number = order.number

      order_params = {
          amount: order.total.to_f,
          description: "Spree Order ID: #{order_number}",
          redirectUrl: spree_routes.mollie_validate_payment_mollie_url(order_number: order_number, host: get_preference(:hostname)),
          webhookUrl: spree_routes.mollie_update_payment_status_mollie_url(order_number: order_number, host: get_preference(:hostname)),
          method: source.payment_method_name,
          metadata: {
              order_id: order_number
          },
          api_key: get_preference(:api_key),
      }

      if order.user_id.present?
        if source.payment_method_name.match(Regexp.union([::Mollie::Method::BITCOIN, ::Mollie::Method::BANKTRANSFER, ::Mollie::Method::GIFTCARD]))
          order_params.merge! ({
              billingEmail: order.user.email
          })
        end

        # Allow single click payments by passing Mollie customer ID
        if order.user.mollie_customer_id.present?
          order_params.merge! ({
              customerId: order.user.mollie_customer_id
          })
        end
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

      unless payment.completed?
        case transaction.status
          when 'paid'
            payment.complete! unless payment.completed?
            payment.order.finalize!
            payment.order.update_attributes(:state => 'complete', :completed_at => Time.now)
          when 'cancelled', 'expired', 'failed'
            payment.failure! unless payment.failed?
          else
            logger.debug 'Unhandled Mollie payment state received. Therefore we did not update the payment state.'
        end
      end

      payment.source.update(status: payment.state)
    end

    private
    def invalidate_prev_transactions(current_payment_id)
      # Cancel all previous payment which are pending or are still being processed
      payments.with_state('processing').or(payments.with_state('pending')).where.not(id: current_payment_id).each do |payment|
        # Set internal payment state to failed
        payment.failure! unless payment.store_credit?
      end
    end
  end
end
