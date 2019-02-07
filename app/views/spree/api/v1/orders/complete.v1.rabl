child available_payment_methods: :payment_methods do
  attributes :id, :name, :method_type

  node :gateways do |payment_method|
    payment_method.gateways(order: @order) if @order.present?
  end
end