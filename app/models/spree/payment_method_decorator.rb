Spree::PaymentMethod.class_eval do

  def gateways(options = {})
    []
  end

end