module Spree
  module Mollie
    class OrderSerializer
      include ::Spree::Mollie::MoneyFormatter

      def self.serialize(total_amount, source, gateway_options, gateway_preferences)
        new(total_amount, source, gateway_options, gateway_preferences).serialize
      end

      def initialize(total_amount, source, gateway_options, gateway_preferences)
        @total_amount = total_amount
        @source = source
        @gateway_options = gateway_options
        @gateway_preferences = gateway_preferences
        @order = gateway_options[:order]
      end

      def serialize
        spree_routes = ::Spree::Core::Engine.routes.url_helpers
        currency = @gateway_options[:currency]
        order_number = @gateway_options[:order_id]

        order_params = {
          amount: {
            currency: currency,
            value: format_money(@total_amount)
          },
          metadata: {
            order_number: order_number
          },
          orderNumber: order_number,
          redirectUrl: spree_routes.mollie_validate_payment_mollie_url(
            order_number: order_number,
            host: @gateway_preferences[:hostname]
          ),
          webhookUrl: spree_routes.mollie_update_payment_status_mollie_url(
            order_number: order_number,
            host: @gateway_preferences[:hostname]
          ),
          locale: 'en_US',
          api_key: @gateway_preferences[:api_key]
        }

        if @gateway_options[:billing_address].present?
          order_params.merge! ({
            billingAddress: serialize_address(@gateway_options[:billing_address])
          })
        end

        if @gateway_options[:shipping_address].present?
          order_params.merge! ({
            shippingAddress: serialize_address(@gateway_options[:shipping_address])
          })
        end

        order_params.merge! ({
          lines: prepare_line_items
        })

        # User has already selected a payment method
        if @source.try(:payment_method_name).present?
          order_params.merge! ({
            method: @source.payment_method_name
          })
        end

        # User has selected an issuer (available for iDEAL payments)
        if @source.try(:issuer).present?
          order_params.merge! ({
            payment: {
              issuer: @source.issuer
            }
          })
        end

        order_params
      end

      private

      def prepare_line_items
        order_lines = []
        @order.line_items.each do |line|
          order_lines << serialize_line_item(line)
        end
        if @order.has_order_adjustments?
          order_lines << serialize_discounts
        end
        order_lines << serialize_shipping_costs
      end

      def serialize_address(address)
        {
          streetAndNumber: address[:address1],
          city: address[:city],
          postalCode: address[:zip],
          country: address[:country],
          region: address[:state],
          givenName: address[:firstname],
          familyName: address[:lastname],
          email: @order.email
        }
      end

      def serialize_shipping_costs
        {
          type: 'shipping_fee',
          name: 'Shipping costs',
          quantity: 1,
          unitPrice: {
            currency: @order.currency,
            value: format_money(@order.display_ship_total.money)
          },
          totalAmount: {
            currency: @order.currency,
            value: format_money(@order.display_ship_total.money)
          },
          vatAmount: {
            currency: @order.currency,
            value: '0.00'
          },
          vatRate: '0'
        }
      end

      def serialize_discounts
        {
          type: 'discount',
          name: 'Order discount',
          quantity: 1,
          unitPrice: {
            currency: @order.currency,
            value: format_money(@order.display_order_adjustment_total.money)
          },
          totalAmount: {
              currency: @order.currency,
              value: format_money(@order.display_order_adjustment_total.money)
          },
          vatAmount: {
              currency: @order.currency,
              value: '0.00'
          },
          vatRate: '0'
        }
      end

      def serialize_line_item(line)
        {
          type: 'physical',
          name: line.name,
          quantity: line.quantity,
          unitPrice: {
            currency: line.currency,
            value: format_money(line.display_price.money)
          },
          discountAmount: {
            currency: line.currency,
            value: format_money(line.display_discount_amount.money)
          },
          totalAmount: {
            currency: line.currency,
            value: format_money(line.display_final_amount.money)
          },
          vatAmount: {
            currency: line.currency,
            value: format_money(line.display_vat_amount.money)
          },
          vatRate: line.vat_rate * 100,
          sku: "#{line.id}-#{line.variant.sku}"
        }
      end
    end
  end
end
