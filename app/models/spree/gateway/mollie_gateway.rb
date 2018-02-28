module Spree
  class Gateway::MollieGateway < PaymentMethod
    preference :api_key, :string

    has_many :spree_mollie_transactions, class_name: 'Spree::MollieTransaction'

    GATEWAY_NAME = 'Mollie'

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

    def name
      return GATEWAY_NAME if payments.none? || payments.last.source.nil?

      case payments.last.source.payment_method_name
        when ::Mollie::Method::IDEAL then
          'iDEAL'
        when ::Mollie::Method::CREDITCARD then
          'Credit card'
        when ::Mollie::Method::MISTERCASH then
          'Bancontact'
        when ::Mollie::Method::SOFORT then
          'SOFORT Banking'
        when ::Mollie::Method::BANKTRANSFER then
          'Bank transfer'
        when ::Mollie::Method::BITCOIN then
          'Bitcoin'
        when ::Mollie::Method::PAYPAL then
          'PayPal'
        when ::Mollie::Method::KBC then
          'KBC/CBC Payment Button'
        when ::Mollie::Method::BELFIUS then
          'Belfius Pay Button'
        when ::Mollie::Method::PAYSAFECARD then
          'paysafecard'
        when ::Mollie::Method::PODIUMCADEAUKAART then
          'Podium Cadeaukaart'
        when ::Mollie::Method::GIFTCARD then
          'Giftcard'
        when ::Mollie::Method::INGHOMEPAY then
          'ING Home\'Pay'
        else
          'Mollie'
      end
    end

    # Create a new transaction
    def create_transaction(money, source, gateway_options)
      payment = payments.last
      transaction = ::Mollie::Payment.create(
          prepare_transaction_params(payment.order, source)
      )

      invalidate_prev_transactions(payment.id)

      payment.response_code = transaction.id
      payment.save!

      source.payment_id = transaction.id
      source.payment_url = transaction.payment_url
      source.save!

      ActiveMerchant::Billing::Response.new(true, 'Transaction created')
    end

    def prepare_transaction_params(order, source)
      order_number = order.number
      order_params = {
          amount: order.total.to_f,
          description: "Spree Order ID: #{order_number}",
          redirectUrl: "http://spree.vndg.com:3000/mollie/validate_payment/#{order_number}",
          webhookUrl: "https://a775808b.ngrok.io/mollie/update_payment_status/#{order_number}",
          method: source.payment_method_name,
          metadata: {
              order_id: order_number
          },
          api_key: get_preference(:api_key),
      }

      # Add additional information based on payment method.
      if order.user_id.present?
        if source.payment_method_name.match(Regexp.union([::Mollie::Method::BITCOIN, ::Mollie::Method::BANKTRANSFER, ::Mollie::Method::GIFTCARD]))
          order_params.merge! ({
              billingEmail: order.user.email
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
