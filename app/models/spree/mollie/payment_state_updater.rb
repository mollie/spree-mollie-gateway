module Spree
  module Mollie
    class PaymentStateUpdater
      def self.update(*args)
        new(*args).update
      end
    end
  end
end
