module Spree
  module Mollie
    class PaymentStateUpdater
      def self.update(mollie_order, spree_payment)
        new(mollie_order, spree_payment).update
      end

      def initialize(mollie_order, spree_payment)
        @mollie_order = mollie_order
        @spree_payment = spree_payment
      end

      def update
        case @mollie_order.status
        when 'paid', 'completed'
          transition_to_paid!
        when 'canceled', 'expired'
          transition_to_failed!
        when 'authorized'
          transition_to_authorized!
        when 'shipping'
          transition_to_shipping!
        else
          MollieLogger.debug("Unhandled Mollie payment state received: #{@mollie_order.status}. Therefore we did not update the payment state.")
          @spree_payment.order.update_attributes(state: 'payment', completed_at: nil)
        end

        @spree_payment.source.update(status: @spree_payment.state)
      end

      private

      def transition_to_paid!
        if @spree_payment.completed?
          MollieLogger.debug('Payment is already completed. Not updating the payment status within Spree.')
          return
        end

        # If order is already paid for, don't mark it as complete again.
        @spree_payment.complete!
        MollieLogger.debug('Mollie order has been paid for.')
        complete_order!
      end

      def transition_to_failed!
        @spree_payment.failure! unless @spree_payment.failed?
        @spree_payment.order.update_attributes(state: 'payment', completed_at: nil)
        MollieLogger.debug("Mollie order is #{@mollie_order.status} and will be marked as failed")
      end

      def transition_to_authorized!
        @spree_payment.pend! unless @spree_payment.pending?
        MollieLogger.debug("Mollie order #{@mollie_order.id} has been authorized.")
        complete_order!
      end

      def transition_to_shipping!
        MollieLogger.debug("Mollie order #{@mollie_order.id} is shipping, update to partial shipping.")
      end

      def complete_order!
        @spree_payment.order.finalize!
        @spree_payment.order.update_attributes(state: 'complete', completed_at: Time.now)
        MollieLogger.debug('Order will be finalized and order confirmation will be sent.')
      end
    end
  end
end
