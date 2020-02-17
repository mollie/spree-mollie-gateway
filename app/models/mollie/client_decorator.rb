module Mollie::ClientDecorator
  attr_accessor :version_strings

  def initialize(api_key = nil)
    @api_endpoint = Mollie::Client::API_ENDPOINT
    @api_key = api_key
    @version_strings = []

    add_version_string 'MollieSpreeCommerce/' << SpreeMollieGateway::VERSION
    add_version_string 'Ruby/' << RUBY_VERSION
    add_version_string OpenSSL::OPENSSL_VERSION.split(' ').slice(0, 2).join '/'
  end
end

Mollie::Client.prepend(Mollie::ClientDecorator)