FactoryBot.define do
  # Creditcard payment
  factory :mollie_cc_payment_source, class: Spree::MolliePaymentSource do
    payment_method_name 'creditcard'
    status 'open'
  end

  # iDEAL payment
  factory :mollie_ideal_payment_source, class: Spree::MolliePaymentSource do
    payment_method_name 'ideal'
    issuer 'ideal_ABNANL2A'
    status 'open'
  end
end
