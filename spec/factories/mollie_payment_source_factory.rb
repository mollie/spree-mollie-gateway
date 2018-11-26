FactoryBot.define do
  # Credit card payment
  factory :mollie_payment_source, class: Spree::MolliePaymentSource do
    payment_method_name { 'creditcard' }
    status { 'open' }
  end
end
