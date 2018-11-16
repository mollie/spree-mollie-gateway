FactoryBot.define do
  factory :mollie_payment, class: Spree::Payment do
    amount { 29.99 }
    association(:payment_method, factory: :mollie_gateway)
    association(:source, factory: :mollie_payment_source)
    order
    state { 'checkout' }
  end
end
