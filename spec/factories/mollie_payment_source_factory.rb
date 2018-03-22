FactoryBot.define do
  factory :mollie_payment_source, class: Spree::MolliePaymentSource do
    payment_method_name 'ideal'
    issuer 'ideal_TESTNL99'
    status 'open'
  end
end
