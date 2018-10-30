FactoryBot.define do
  factory :mollie_api_payment, class: Mollie::Payment do
    skip_create
    initialize_with {new([])}
  end
end
