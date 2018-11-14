Spree::Order.class_eval do
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

    touch :completed_at

    puts "confirmation_delivered: #{confirmation_delivered?}"
    puts "paid?: #{paid?}"
    puts "authorized?: #{authorized?}"

    if !confirmation_delivered? && (paid? || authorized?)
      deliver_order_confirmation_email
    end

    consider_risk
  end

  def authorized?
    payments.last.authorized?
  end
end
