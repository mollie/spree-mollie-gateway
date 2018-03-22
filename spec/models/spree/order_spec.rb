require 'spec_helper'

RSpec.describe Spree::Order, type: :model do
  let(:gateway) {create(:mollie_gateway, auto_capture: true)}
  let(:payment) {create(:mollie_payment, payment_method: gateway)}
  let(:payment_source) {payment.payment_source}
  let(:order) {OrderWalkthrough.up_to(:payment)}
  let(:process_mollie_payment!) {payment.process!}
  let(:add_payment_to_order!) {order.payments << payment}

  describe 'complete with Mollie payment' do
    let!(:complete_order!) do
      add_payment_to_order!
      order.next!
    end

    it 'should set payment state to pending' do
      expect(payment.reload.state).to eq 'pending'
    end

    it 'should set order state to complete' do
      expect(order.state).to eq 'complete'
    end

    it 'should set a payment_url' do
      expect(payment.source.payment_url).to include 'https://www.mollie.com/paymentscreen/'
    end

    it 'should delegate transaction_id to its source' do
      expect(payment.transaction_id).to eq payment.source.transaction_id
      expect(payment.transaction_id).to eq payment.source.payment_id
    end
  end

  describe 'checkout steps' do
    it 'should not include confirmation step by default' do
      expect(order.checkout_steps).not_to include 'confirm'
    end

    it 'should include payment step by default' do
      expect(order.checkout_steps).to include 'payment'
    end

    context 'with braintree dropin payment' do
      before {add_payment_to_order!}

      it 'should include payment step' do
        expect(order.checkout_steps).to include 'payment'
      end
    end
  end
end