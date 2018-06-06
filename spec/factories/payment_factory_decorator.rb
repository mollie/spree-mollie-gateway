FactoryBot.define do
  factory :mollie_payment, class: Spree::Payment do
    amount 12.73
    association(:payment_method, factory: :mollie_gateway)
    association(:source, factory: :mollie_cc_payment_source)
    order
    state 'checkout'
  end

  factory :mollie_multicurrency_payment, class: Spree::Payment do
    amount 12.73
    association(:payment_method, factory: :mollie_gateway)
    association(:source, factory: :mollie_ideal_payment_source)
    order
    state 'checkout'
  end
end