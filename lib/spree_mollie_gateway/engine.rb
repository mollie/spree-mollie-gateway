require 'mollie-api-ruby'

module SpreeMollieGateway
  class Engine < ::Rails::Engine
    isolate_namespace SpreeMollieGateway

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      ::Rails.application.config.spree.payment_methods << Spree::Gateway::MollieGateway
      Spree::PermittedAttributes.source_attributes << :payment_method_name
      Spree::PermittedAttributes.source_attributes << :issuer
      Spree::Api::ApiHelpers.payment_source_attributes << :payment_method_name
      Spree::Api::ApiHelpers.payment_source_attributes << :issuer
      Spree::Api::ApiHelpers.payment_source_attributes << :payment_url
    end

    config.to_prepare &method(:activate).to_proc
  end
end