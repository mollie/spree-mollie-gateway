Spree::Api::V1::CheckoutsController.class_eval do
  def update
    authorize! :update, @order, order_token

    if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
      if current_api_user.has_spree_role?('admin') && user_id.present?
        @order.associate_user!(Spree.user_class.find(user_id))
      end

      if paying_with_mollie?
        payment = @order.
        payment.create_transaction!
      end

      return if after_update_attributes

      if @order.completed? || @order.next
        state_callback(:after)
        respond_with(@order, default_template: 'spree/api/v1/orders/show')
      else
        respond_with(@order, default_template: 'spree/api/v1/orders/could_not_transition', status: 422)
      end
    else
      invalid_resource!(@order)
    end
  end

  private
  def paying_with_mollie?
    if params[:order][:payments_attributes].present?
      payment_method_id = params[:order][:payments_attributes].first[:payment_method_id]
      return Spree::PaymentMethod.find(payment_method_id).is_a? ::Spree::Gateway::MollieGateway
    end
  end
end