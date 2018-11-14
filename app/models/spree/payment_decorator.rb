Spree::Payment.class_eval do
  def transaction_id
    if payment_method.is_a? Spree::Gateway::MollieGateway
      source.transaction_id
    else
      response_code
    end
  end

  def build_source
    return unless new_record?

    if source_attributes.present? && source.blank? && payment_method.try(:payment_source_class)
      self.source = payment_method.payment_source_class.new(source_attributes)
      source.payment_method_id = payment_method.id
      source.user_id = order.user_id if order

      # Spree will not process payments if order is completed.
      # We should call process! for completed orders to create a new Mollie payment.
      process! if order.completed?
    end
  end

  def authorized?
    if source.is_a? Spree::MolliePaymentSource
      pending?
    else
      false
    end
  end
end
