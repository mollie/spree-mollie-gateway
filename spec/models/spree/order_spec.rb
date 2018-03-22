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
  end

end