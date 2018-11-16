Spree::PaymentMethod.class_eval do
  def gateways(_options = {})
    []
  end
end
