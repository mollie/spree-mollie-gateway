Spree::Payment::Processing.module_eval do
  def process!(amount = nil)
    if payment_method.is_a? Spree::Gateway::MollieGateway
      process_with_mollie
    else
      process_with_spree
    end
  end

  private

  def process_with_spree
    if payment_method && payment_method.auto_capture?
      purchase!
    else
      authorize!
    end
  end

  def process_with_mollie
    amount ||= money.money.cents
    started_processing!
    response = payment_method.create_transaction(
        amount,
        source,
        gateway_options
    )
    handle_response(response, :pend, :failure)
  end
end
