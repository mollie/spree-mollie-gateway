module Spree::PaymentMethodDecorator
  def gateways(_options = {})
    []
  end
end

Spree::PaymentMethod.prepend(Spree::PaymentMethodDecorator)
