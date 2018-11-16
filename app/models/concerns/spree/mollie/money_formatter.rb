module Spree
  module Mollie
    module MoneyFormatter
      include ActiveSupport::Concern

      def format_money(money)
        money.format(symbol: nil, thousands_separator: nil, decimal_mark: '.')
      end
    end
  end
end
