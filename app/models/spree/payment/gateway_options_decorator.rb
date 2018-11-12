Spree::Payment::GatewayOptions.class_eval do
  def hash_methods
    %i[
      email
      customer
      customer_id
      ip
      order_id
      shipping
      tax
      subtotal
      discount
      currency
      billing_address
      shipping_address
      order
    ]
  end
end
