module Spree
  class MollieController < BaseController
    skip_before_action :verify_authenticity_token, :only => [:update_payment_status]

    # When the user is redirected from Mollie back to the shop, we can check the
    # mollie transaction status and set the Spree order state accordingly.
    def validate_payment
      order = Spree::Order.find_by_number(params[:order_number])
      payment = order.payments.last
      mollie = Spree::PaymentMethod.find_by_type('Spree::Gateway::MollieGateway')
      mollie.update_payment_status(payment)

      MollieLogger.debug("Redirect URL visited for order #{params[:order_number]}")

      redirect_to order.reload.paid? ? order_path(order) : checkout_state_path(:payment)
    end

    # Mollie might send us information about a transaction through the webhook.
    # We should update the payment state accordingly.
    def update_payment_status
      payment = Spree::Payment.find_by_response_code(params[:id])
      mollie = Spree::PaymentMethod.find_by_type('Spree::Gateway::MollieGateway')
      mollie.update_payment_status(payment)

      MollieLogger.debug("Webhook called for payment #{params[:id]}")

      render json: 'OK'
    end
  end
end