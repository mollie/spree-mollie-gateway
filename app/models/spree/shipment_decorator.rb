module Spree
  module ShipmentDecorator
    private

    def after_ship
      super
      create_mollie_shipment!
    end

    def create_mollie_shipment!
      mollie_order = order.mollie_order
      shipment = ::Mollie::Order::Shipment.create(
          order_id: mollie_order.id,
          lines: shippable_lines,
          tracking: {
              carrier: 'PostNL',
              code: '3SKABA000000000',
              url: 'http://postnl.nl/tracktrace/?B=3SKABA000000000&P=1016EE&D=NL&T=C'
          },
          api_key: gateway_api_key
      )
      MollieLogger.debug("Created Mollie shipment #{shipment.id} for order #{order.id}")
    end

    def shippable_lines
      mollie_order = order.mollie_order
      inventory_units.map do |unit|
        {
            id: mollie_order.get_line_by_id(unit.line_item.id).id,
            quantity: unit.quantity
        }
      end
    end

    def gateway_api_key
      gateway = Spree::PaymentMethod.find_by_type 'Spree::Gateway::MollieGateway'
      gateway.get_preference(:api_key)
    end
  end
end

Spree::Shipment.prepend Spree::ShipmentDecorator