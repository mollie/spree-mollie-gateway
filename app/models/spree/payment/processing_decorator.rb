Spree::Payment::Processing.module_eval do
  def create_transaction!
    started_processing!
    gateway_action(source, :create_transaction, :pend)
  end
end