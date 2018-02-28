module Spree
  module CheckoutWithMollie
    def update
      if payment_params_valid? && paying_with_mollie?
        if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
          payment = @order.payments.last
          payment.create_transaction!
          mollie_payment_url = payment.payment_source.payment_url

          redirect_to mollie_payment_url
        else
          render :edit
        end
      else
        super
      end
    end
  end

  CheckoutController.class_eval do
    prepend CheckoutWithMollie
    private

    def payment_method_id_param
      params[:order][:payments_attributes].first[:payment_method_id]
    end

    def paying_with_mollie?
      payment_method = PaymentMethod.find(payment_method_id_param)
      mollie_payment_method?(payment_method)
    end

    def payment_params_valid?
      (params[:state] === 'payment') && params[:order][:payments_attributes]
    end

    def mollie_payment_method?(payment_method)
      payment_method.is_a?(Gateway::MollieGateway)
    end
  end
end