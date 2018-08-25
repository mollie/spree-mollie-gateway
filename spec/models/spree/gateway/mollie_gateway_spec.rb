require 'spec_helper'

RSpec.describe Spree::Gateway::MollieGateway, type: :model do
  let(:gateway) {create(:mollie_gateway, auto_capture: true)}
  let(:payment) {create(:mollie_payment, payment_method: gateway)}
  let(:payment_source) {payment.payment_source}
  let(:order) {OrderWalkthrough.up_to(:payment)}
  let(:process_mollie_payment!) {payment.process!}
  let(:add_payment_to_order!) {order.payments << payment}
  let(:mollie_api_payment) {create(:mollie_api_payment)}

  describe 'payment state updating' do
    let!(:complete_order!) do
      add_payment_to_order!
      order.next!
    end

    context 'with paid Mollie payment' do
      it 'should set payment state to paid for paid Mollie payment' do
        mollie_api_payment.status = 'paid'
        gateway.update_by_mollie_status!(mollie_api_payment, payment)
        expect(payment.state).to eq 'completed'
      end

      it 'should set order state to complete for paid Mollie payment' do
        mollie_api_payment.status = 'paid'
        gateway.update_by_mollie_status!(mollie_api_payment, payment)
        expect(payment.order.state).to eq 'complete'
      end
    end

    it 'should set payment state to failed for cancelled Mollie payment' do
      mollie_api_payment.status = 'canceled'
      gateway.update_by_mollie_status!(mollie_api_payment, payment)
      expect(payment.state).to eq 'failed'
    end

    it 'should set payment state to failed for expired Mollie payment' do
      mollie_api_payment.status = 'expired'
      gateway.update_by_mollie_status!(mollie_api_payment, payment)
      expect(payment.state).to eq 'failed'
    end

    it 'should set payment state to failed for failed Mollie payment' do
      mollie_api_payment.status = 'failed'
      gateway.update_by_mollie_status!(mollie_api_payment, payment)
      expect(payment.state).to eq 'failed'
    end

    context 'payment method' do
      it 'should have a list of payment methods' do
        expect(gateway.available_methods.first).to be_an_instance_of(Mollie::Method)
      end

      it 'should have nested issuers on payment methods' do
        expect(gateway.available_methods.first.issuers.first).to include('name' => 'ABN AMRO', 'image' => {'size1x' => 'https://www.mollie.com/external/icons/ideal-issuers/ABNANL2A.png', 'size2x' => 'https://www.mollie.com/external/icons/ideal-issuers/ABNANL2A%402x.png', 'svg' => 'https://www.mollie.com/external/icons/ideal-issuers/ABNANL2A.svg'}, 'resource' => 'issuer')
      end
    end
  end
end