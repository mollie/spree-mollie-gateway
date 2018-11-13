module Spree
  class MollieController < BaseController
    skip_before_action :verify_authenticity_token, only: [:update_payment_status]

    # When the user is redirected from Mollie back to the shop, we can check the
    # mollie transaction status and set the Spree order state accordingly.
    def validate_payment
      order_number, payment_number = split_payment_identifier params[:order_number]
      payment = Spree::Payment.find_by_number payment_number
      order = Spree::Order.find_by_number order_number
      mollie = Spree::PaymentMethod.find_by_type 'Spree::Gateway::MollieGateway'
      mollie.update_payment_status payment

      MollieLogger.debug("Redirect URL visited for order #{params[:order_number]}")

      redirect_to order.reload.paid? ? order_path(order) : checkout_state_path(:payment)
    end

    # Mollie might send us information about a transaction through the webhook.
    # We should update the payment state accordingly.
    def update_payment_status
      MollieLogger.debug("Webhook called for Mollie order #{params[:id]}")

      payment = Spree::MolliePaymentSource.find_by_payment_id(params[:id]).payments.first
      mollie = Spree::PaymentMethod.find_by_type 'Spree::Gateway::MollieGateway'
      mollie.update_payment_status payment

      head :ok
    end

    private

    # Payment identifier is a combination of order_number and payment_id.
    def split_payment_identifier(payment_identifier)
      payment_identifier.split '-'
    end
  end
end
