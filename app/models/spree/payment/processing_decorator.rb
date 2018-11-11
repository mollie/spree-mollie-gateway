Spree::Payment::Processing.module_eval do
  def process!(amount = nil)
    if payment_method.is_a? Spree::Gateway::MollieGateway
      process_with_mollie
    else
      process_with_spree
    end
  end

  def cancel!
    if payment_method.is_a? Spree::Gateway::MollieGateway
      cancel_with_mollie
    else
      cancel_with_spree
    end
  end

  private

  def cancel_with_spree
    response = payment_method.cancel(response_code)
    handle_response(response, :void, :failure)
  end

  def cancel_with_mollie
    response = payment_method.cancel(transaction_id)
    handle_response(response, :void, :failure)
  end

  def process_with_spree
    if payment_method && payment_method.auto_capture?
      purchase!
    else
      authorize!
    end
  end

  def process_with_mollie
    amount ||= money.money
    started_processing!
    response = payment_method.process_order(
        amount,
        source,
        gateway_options
    )
    handle_response(response, :pend, :failure)
  end
end
