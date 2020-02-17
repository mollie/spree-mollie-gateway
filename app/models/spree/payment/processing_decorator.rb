module Spree::Payment::ProcessingDecorator
  
  def process!
    if payment_method.is_a? Spree::Gateway::MollieGateway
      process_with_mollie
    else
      super
    end
  end

  def cancel!
    if payment_method.is_a? Spree::Gateway::MollieGateway
      cancel_with_mollie
    else
      super
    end
  end

  private

  def cancel_with_mollie
    response = payment_method.cancel(transaction_id)
    handle_response(response, :void, :failure)
  end

  def process_with_mollie
    amount ||= money.money
    started_processing!
    response = payment_method.process(
      amount,
      source,
      gateway_options
    )
    handle_response(response, :started_processing, :failure)
  end
end

Spree::Payment.include(Spree::Payment::ProcessingDecorator)