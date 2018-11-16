FactoryBot.define do
  factory :mollie_gateway, class: Spree::Gateway::MollieGateway do
    name { 'Mollie Payment Gateway' }

    before(:create) do |gateway|
      gateway.preferences[:api_key] = ENV['MOLLIE_API_KEY']
      gateway.preferences[:hostname] = 'https://mollie.com'
    end
  end
end
