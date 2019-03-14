module Spree
  module ShipmentDecorator
    include ::Spree::Mollie::MoneyFormatter

    private

    def after_ship
      super
      create_mollie_shipment! if order.try(:is_paid_with_mollie?)
    end

    def create_mollie_shipment!
      mollie_order = order.mollie_order
      shipment = create_shipment(mollie_order.id, shippable_lines)
      MollieLogger.debug("Created Mollie shipment #{shipment.id} for order #{order.number}")
    end

    def shipping_costs(mollie_order)
      mollie_order.shipping_fees.map do |fee|
        {
          id: fee.id,
          quantity: fee.quantity
        }
      end
    end

    def discounted_lines(mollie_order)
      mollie_order.discounts.map do |discount|
        {
          id: discount.id,
          quantity: discount.quantity
        }
      end
    end

    def create_shipment(order_id, lines)
      ::Mollie::Order::Shipment.create(
        order_id: order_id,
        lines: lines,
        tracking: {
          carrier: shipping_method.name,
          code: tracking
        },
        api_key: gateway_api_key
      )
    end

    def shippable_lines
      mollie_order = order.mollie_order

      order_lines = inventory_units.map do |unit|
        mollie_order_line = mollie_order.get_line_by_id(unit.line_item.id)
        quantity = unit.quantity
        params = {
          id: mollie_order_line.id,
          quantity: quantity
        }

        # We need to specify the amount when partially shipping discounted inventory units
        if mollie_order_line.discount_amount.present?
          line_total = line_item_shipment_price(unit.line_item, quantity)
          params.merge! ({
            amount: {
              currency: order.currency,
              value: format_money(line_total)
            }
          })
        end

        params
      end

      # Charge shipping costs and discounts within the same shipment if there are any
      if mollie_order.collect_fees_on_first_shipment?
        if mollie_order.shipping_fees.any?
          order_lines << shipping_costs(mollie_order)
        end

        if mollie_order.discounts.any?
          order_lines << discounted_lines(mollie_order)
        end
      end

      order_lines.flatten
    end

    def line_item_shipment_price(line_item, unit_quantity)
      line_item_price = line_item.display_final_amount.money / line_item.quantity
      line_item_price * unit_quantity
    end

    def gateway_api_key
      gateway = Spree::PaymentMethod.find_by_type 'Spree::Gateway::MollieGateway'
      gateway.get_preference(:api_key)
    end
  end
end

Spree::Shipment.prepend Spree::ShipmentDecorator
