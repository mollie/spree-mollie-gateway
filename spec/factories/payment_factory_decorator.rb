FactoryBot.define do
  factory :mollie_payment, class: Spree::Payment do
    amount 12.73
    association(:payment_method, factory: :mollie_gateway)
    association(:source, factory: :mollie_payment_source)
    order
    state 'checkout'
  end
end