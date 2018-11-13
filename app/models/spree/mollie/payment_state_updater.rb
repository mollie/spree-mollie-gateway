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
          create_spree_shipment!
        else
          MollieLogger.debug('Unhandled Mollie payment state received. Therefore we did not update the payment state.')
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
        @spree_payment.order.finalize!
        @spree_payment.order.update_attributes(state: 'complete', completed_at: Time.now)
        MollieLogger.debug('Mollie order is paid and will transition its Spree state to completed. Order will be finalized and order confirmation will be sent.')
      end

      def transition_to_failed!
        @spree_payment.failure! unless @spree_payment.failed?
        @spree_payment.order.update_attributes(state: 'payment', completed_at: nil)
        MollieLogger.debug("Mollie order is #{@mollie_order.status} and will be marked as failed")
      end

      def transition_to_authorized!
        MollieLogger.debug("Mollie order #{@mollie_order.id} has been authorized")
      end

      # @todo: Fetch Mollie lines and match with Spree order lines, create shipments where needed.
      def create_spree_shipment!
        MollieLogger.debug("Mollie Order #{@mollie_order.id} is shipping. Syncing order lines and creating shipments if necessary.")
      end
    end
  end
end
