FactoryBot.define do
  factory :mollie_payment_source, class: Spree::MolliePaymentSource do
    payment_method_name 'ideal'
    issuer 'ideal_ABNANL2A'
    status 'open'
  end
end
