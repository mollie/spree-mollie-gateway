
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "spree_mollie_gateway/version"

Gem::Specification.new do |spec|
  spec.name          = "spree_mollie_gateway"
  spec.version       = SpreeMollieGateway::VERSION
  spec.authors       = ["Vernon de Goede"]
  spec.email         = ["vernon@mollie.com"]

  spec.summary       = %q{Mollie payments for Spree Commerce.}
  spec.description   = %q{Mollie payment gateway for Spree Commerce.}
  spec.homepage      = "https://www.mollie.com"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency 'mollie-api-ruby', '~> 3.1', '>= 3.1.3'
end
