Spree::Core::Engine.add_routes do
  resource :mollie, only: [], controller: :mollie do
    post 'update_payment_status/:order_number', action: :update_payment_status, as: 'mollie_update_payment_status'
    get 'validate_payment/:order_number', action: :validate_payment, as: 'mollie_validate_payment'
  end
end