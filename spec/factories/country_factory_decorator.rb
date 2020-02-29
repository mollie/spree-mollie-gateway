FactoryBot.modify do
  factory :country, class: Spree::Country do
    sequence(:iso)     { 'US' }
    sequence(:iso3)    { 'USA' }
  end
end
