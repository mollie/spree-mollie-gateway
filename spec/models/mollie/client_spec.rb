require 'spec_helper'

RSpec.describe Mollie::Client, type: :model do
  let(:client) { Mollie::Client.new }

  it 'set the correct version string' do
    expect(client.version_strings.first).to include 'MollieSpreeCommerce'
  end
end
