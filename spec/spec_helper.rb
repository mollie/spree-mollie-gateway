# require 'bundler/setup'
# require 'action_controller/railtie'

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)

require 'rspec/rails'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

# Requires factories and other useful helpers defined in spree_core.
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/factories'
require 'spree/testing_support/order_walkthrough'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Ensure Suite is set to use transactions for speed.
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.color = true

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
