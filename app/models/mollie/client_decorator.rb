Mollie::Client.class_eval do
  def initialize(api_key = nil)
    @api_endpoint = Mollie::Client::API_ENDPOINT
    @api_key = api_key
    @version_strings = []

    add_version_string 'Mollie for Spree Commerce/' << Mollie::VERSION
    add_version_string 'Ruby/' << RUBY_VERSION
    add_version_string OpenSSL::OPENSSL_VERSION.split(' ').slice(0, 2).join '/'
  end
end