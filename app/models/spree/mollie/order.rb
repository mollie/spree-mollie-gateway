module Spree
  module Mollie
    class Order
      def initialize(order)
        @order = order
        @mollie_order = mollie_order
      end

      attr_accessor :mollie_order, :order

      def mollie_order
        ::Mollie::Order.get(mollie_order_id,
                            api_key: api_key)
      end

      def get_line_by_id(line_item_id)
        @mollie_order.lines.detect { |line| line.sku.start_with?("#{line_item_id}-") }
      end

      def id
        @mollie_order.id
      end

      def shipping_fees
        @mollie_order.lines.select { |line| line.type === 'shipping_fee' && line.status === 'authorized' }
      end

      def discounts
        @mollie_order.lines.select { |line| line.type === 'discount' && line.status === 'authorized' }
      end

      def collect_fees_on_first_shipment?
        gateway.get_preference(:collect_shipping_costs_and_discounts_on_first_shipment)
      end

      private

      def mollie_order_id
        payment.source.payment_id
      end

      def has_mollie_order?
        payment.source.is_a? Spree::MolliePaymentSource
      end

      def payment
        @order.payments.last
      end

      def gateway
        Spree::PaymentMethod.find_by_type 'Spree::Gateway::MollieGateway'
      end

      def api_key
        gateway.get_preference(:api_key)
      end
    end
  end
end
