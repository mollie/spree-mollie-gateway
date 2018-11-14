require 'spec_helper'

RSpec.describe Spree::Mollie::OrderSerializer, type: :model do
  let(:order) {create :order_with_line_items, line_items_count: 1}
  let(:gateway) {create(:mollie_gateway, auto_capture: true)}
  let(:payment) {create(:mollie_payment, payment_method: gateway)}
  let(:payment_source) {payment.payment_source}
  let(:line_item) {order.line_items.first}
  let(:line_item_promo) do
    create(:promotion,
           :with_line_item_adjustment,
           :with_item_total_rule,
           adjustment_rate: 2.5,
           item_total_threshold_amount: 10)
  end
  let(:order_total) {Spree::Money.new(19.99).money}
  let(:gateway_preferences) {{
      api_key: ENV['MOLLIE_API_KEY'],
      hostname: 'https://mollie.com'
  }}

  let!(:add_promotion_to_line_item!) do
    line_item_promo.activate order: order
    order.save
    order.reload
  end

  let!(:transition_to_payment_step!) do
    2.times {order.next!}
  end

  it 'should have the correct setup' do
    expect(order.item_total.to_s).to eq("19.99")
    expect(order.total.to_s).to eq('17.49')
    expect(order.adjustment_total.to_s).to eq('-2.5')
    expect(order.line_items.first.adjustments.first.amount.to_s).to eq('-2.5')
  end

  context 'serialization' do
    let(:serialized_order) {Spree::Mollie::OrderSerializer.serialize(order_total, payment_source, payment.gateway_options, gateway_preferences)}

    it 'should contain amount' do
      expect(serialized_order[:amount][:currency]).to eq 'USD'
      expect(serialized_order[:amount][:value]).to eq '19.99'
    end

    it 'should contain orderNumber' do
      expect(serialized_order[:metadata][:order_number]).not_to be_empty
      expect(serialized_order[:orderNumber]).to eq serialized_order[:metadata][:order_number]
    end

    it 'should contain redirectUrl' do
      expect(serialized_order[:redirectUrl]).to include("https://mollie.com")
      expect(serialized_order[:redirectUrl]).to include(serialized_order[:metadata][:order_number])
    end

    it 'should contain webhookUrl' do
      expect(serialized_order[:webhookUrl]).to include("https://mollie.com")
      expect(serialized_order[:webhookUrl]).to include(serialized_order[:metadata][:order_number])
    end

    it 'should have a locale' do
      expect(serialized_order[:locale]).not_to be_empty
    end

    it 'should have an api-key' do
      expect(serialized_order[:api_key]).not_to be_empty
    end

    it 'should contain the selected payment method' do
      expect(serialized_order[:method]).to eq 'creditcard'
    end

    context 'billing_address' do
      let(:billing_address) {serialized_order[:billingAddress]}

      it 'should have a billing address' do
        expect(billing_address).to be_kind_of Hash
      end

      it 'should have streetAndNumber' do
        expect(billing_address[:streetAndNumber]).to eq '10 Lovely Street'
      end

      it 'should have city' do
        expect(billing_address[:city]).to eq 'Herndon'
      end

      it 'should have postalCode' do
        expect(billing_address[:postalCode]).to eq '35005'
      end

      it 'should have country' do
        expect(billing_address[:country]).to eq 'US'
      end

      it 'should have region' do
        expect(billing_address[:region]).not_to be_empty
      end

      it 'should have givenName' do
        expect(billing_address[:givenName]).to eq 'John'
      end

      it 'should have familyname' do
        expect(billing_address[:familyName]).to eq 'Doe'
      end

      it 'should have email' do
        expect(billing_address[:email]).not_to be_empty
      end
    end

    context 'shipping_fee' do
      let(:shipping_fee) {serialized_order[:lines].first}

      it 'should have a quantity of 1' do
        expect(shipping_fee[:quantity]).to eq(1)
      end
    end
  end
end
