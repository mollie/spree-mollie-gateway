Spree::Order.class_eval do
  # Make sure the order confirmation is delivered when the order has been paid for.
  def finalize!
    # lock all adjustments (coupon promotions, etc.)
    all_adjustments.each(&:close)

    # update payment and shipment(s) states, and save
    updater.update_payment_state
    shipments.each do |shipment|
      shipment.update!(self)
      shipment.finalize!
    end

    updater.update_shipment_state
    save!
    updater.run_hooks

    touch :completed_at

    deliver_order_confirmation_email unless confirmation_delivered? or !paid?

    consider_risk
  end

  def update_from_params(params, permitted_params, request_env = {})
    success = false
    payment_attributes = nil
    @updating_params = params
    run_callbacks :updating_from_params do
      # Set existing card after setting permitted parameters because
      # rails would slice parameters containg ruby objects, apparently
      existing_card_id = @updating_params[:order] ? @updating_params[:order].delete(:existing_card) : nil

      attributes = if @updating_params[:order]
                     @updating_params[:order].permit(permitted_params).delete_if { |_k, v| v.nil? }
                   else
                     {}
                   end
      payment_attributes = attributes[:payments_attributes].first if attributes[:payments_attributes].present?

      if existing_card_id.present?
        credit_card = CreditCard.find existing_card_id
        if credit_card.user_id != user_id || credit_card.user_id.blank?
          raise Core::GatewayError, Spree.t(:invalid_credit_card)
        end

        credit_card.verification_value = params[:cvc_confirm] if params[:cvc_confirm].present?

        attributes[:payments_attributes].first[:source] = credit_card
        attributes[:payments_attributes].first[:payment_method_id] = credit_card.payment_method_id
        attributes[:payments_attributes].first.delete :source_attributes
      end

      if payment_attributes.present?
        payment_attributes[:request_env] = request_env
        payment_attributes[:source] = Spree::MolliePaymentSource.create_from_params(params)
      end

      success = update_attributes(attributes)
      set_shipments_cost if shipments.any?
    end

    @updating_params = nil
    success
  end
end