Spree::Payment::Processing.module_eval do
  def process!(amount = nil)
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