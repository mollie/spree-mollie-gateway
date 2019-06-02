require 'spec_helper'

RSpec.describe Spree::Mollie::OrderSerializer, type: :model do
  let(:order) { create :order_with_line_items, line_items_count: 1 }
  let(:gateway) { create(:mollie_gateway, auto_capture: true) }
  let(:payment) { create(:mollie_payment, payment_method: gateway, order: order) }
  let(:calculator) { Calculator::FlatRate.new(preferred_amount: 10) }
  let(:payment_source) { payment.payment_source }
  let(:line_item) { order.line_items.first }
  let(:line_item_promo) do
    create(:promotion,
           :with_line_item_adjustment,
           :with_item_total_rule,
           adjustment_rate: 2.5,
           item_total_threshold_amount: 10)
  end
  let(:order_total) { Spree::Money.new(19.99).money }
  let(:gateway_preferences) do
    {
      api_key: ENV['MOLLIE_API_KEY'],
      hostname: 'https://mollie.com'
    }
  end

  let!(:add_promotion_to_line_item!) do
    line_item_promo.activate order: order
    order.save
    order.reload
  end

  let!(:transition_to_payment_step!) do
    2.times { order.next! }
  end

  it 'has the correct setup' do
    expect(order.item_total.to_s).to eq('19.99')
    expect(order.total.to_s).to eq('17.49')
    expect(order.adjustment_total.to_s).to eq('-2.5')
    expect(order.line_items.first.adjustments.first.amount.to_s).to eq('-2.5')
  end

  context 'serialization' do
    let(:serialized_order) do
      serializer = Spree::Mollie::OrderSerializer.new(
        order_total,
        payment_source,
        payment.gateway_options,
        gateway_preferences
      )
      serializer.serialize
    end

    it 'contains amount' do
      expect(serialized_order[:amount][:currency]).to eq 'USD'
      expect(serialized_order[:amount][:value]).to eq '19.99'
    end

    it 'contains orderNumber' do
      expect(serialized_order[:metadata][:order_number]).not_to be_empty
      expect(serialized_order[:orderNumber]).to eq serialized_order[:metadata][:order_number]
    end

    it 'contains redirectUrl' do
      expect(serialized_order[:redirectUrl]).to include('https://mollie.com')
      expect(serialized_order[:redirectUrl]).to include(serialized_order[:metadata][:order_number])
    end

    it 'contains webhookUrl' do
      expect(serialized_order[:webhookUrl]).to include('https://mollie.com')
      expect(serialized_order[:webhookUrl]).to include(serialized_order[:metadata][:order_number])
    end

    it 'has a locale' do
      expect(serialized_order[:locale]).not_to be_empty
    end

    it 'has an api-key' do
      expect(serialized_order[:api_key]).not_to be_empty
    end

    it 'contains the selected payment method' do
      expect(serialized_order[:method]).to eq 'creditcard'
    end

    context 'billing address' do
      subject { serialized_order[:billingAddress] }

      it 'has a billing address' do
        expect(subject).to be_kind_of Hash
      end

      it 'has streetAndNumber' do
        expect(subject[:streetAndNumber]).to eq '10 Lovely Street Northwest'
      end

      it 'has city' do
        expect(subject[:city]).to eq 'Herndon'
      end

      it 'has postalCode' do
        expect(subject[:postalCode]).to eq '35005'
      end

      it 'has country' do
        expect(subject[:country]).to match(/^.{2}\b$/)
      end

      it 'has region' do
        expect(subject[:region]).not_to be_empty
      end

      it 'has givenName' do
        expect(subject[:givenName]).to eq 'John'
      end

      it 'has familyname' do
        expect(subject[:familyName]).to eq 'Doe'
      end

      it 'has email' do
        expect(subject[:email]).not_to be_empty
      end
    end

    context 'shipping fee' do
      subject { serialized_order[:lines].detect { |line| line[:type] == 'shipping_fee' } }

      let!(:set_ship_total) do
        order.ship_total = 10
        order.save!
      end

      let(:serialized_order) do
        serializer = Spree::Mollie::OrderSerializer.new(
          order_total,
          payment_source,
          payment.gateway_options,
          gateway_preferences
        )
        serializer.serialize
      end

      it 'has a quantity of 1' do
        expect(subject[:quantity]).to eq(1)
      end

      it 'is present' do
        expect(subject).not_to be_empty
      end

      it 'has unitPrice' do
        expect(subject[:unitPrice][:value]).to eq('10.00')
        expect(subject[:unitPrice][:currency]).to eq('USD')
      end

      it 'has no discountAmount' do
        expect(subject[:discountAmount]).to be_nil
      end

      it 'has totalAmount' do
        expect(subject[:totalAmount][:value]).to eq('10.00')
        expect(subject[:totalAmount][:currency]).to eq('USD')
      end
    end

    context 'shipping discount' do
      # Set up free shipping promotion
      subject { serialized_order[:lines].detect { |line| line[:name] == 'Shipping discount' } }

      let(:promotion) { create(:promotion) }
      let(:action) { Spree::Promotion::Actions::FreeShipping.create }
      let(:payload) { { order: order } }

      before do
        order.shipments << create(:shipment)
        promotion.promotion_actions << action
        action.perform(payload)
      end

      let(:serialized_order) do
        serializer = Spree::Mollie::OrderSerializer.new(
          order_total,
          payment_source,
          payment.gateway_options,
          gateway_preferences
        )
        serializer.serialize
      end

      it 'has been applied' do
        expect(order.shipment_adjustments.count).to eq(1)
      end

      it 'is present' do
        expect(subject).not_to be_empty
      end

      it 'has unitPrice' do
        expect(subject[:unitPrice][:value]).to eq('-100.00')
        expect(subject[:unitPrice][:currency]).to eq('USD')
      end

      it 'has no discountAmount' do
        expect(subject[:discountAmount]).to be_nil
      end

      it 'has totalAmount' do
        expect(subject[:totalAmount][:value]).to eq('-100.00')
        expect(subject[:totalAmount][:currency]).to eq('USD')
      end
    end
  end
end
