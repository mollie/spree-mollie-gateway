Spree::Order.class_eval do
  money_methods :order_adjustment_total, :shipping_discount

  # Make sure the order confirmation is delivered when the order has been paid for.
  def finalize!
    # lock all adjustments (coupon promotions, etc.)
    all_adjustments.each(&:close)

    # update payment and shipment(s) states, and save
    updater.update_payment_state
    shipments.each do |shipment|
      shipment.update!(self)
      shipment.finalize! if paid? || authorized?
    end

    updater.update_shipment_state
    save!
    updater.run_hooks

    unless completed?
      update(state: 'complete')
      touch :completed_at
    end

    if !confirmation_delivered? && (paid? || authorized?)
      deliver_order_confirmation_email
    end

    consider_risk
  end

  def is_paid_with_mollie?
    payments.collect(&:payment_method).any? {|pm| pm.type == 'Spree::Gateway::MollieGateway'}
  end

  def send_confirmation_email!
    if !confirmation_delivered? && (paid? || authorized?)
      deliver_order_confirmation_email
    end
  end

  def mollie_order
    Spree::Mollie::Order.new(self)
  end

  def successful_payment
    paid? || payments.any? {|p| p.after_pay_method? && p.authorized?}
  end

  alias paid_or_authorized? successful_payment

  def authorized?
    payments.last.authorized?
  end

  def order_adjustment_total
    adjustments.eligible.sum(:amount)
  end

  def has_order_adjustments?
    order_adjustment_total.abs > 0
  end
end
