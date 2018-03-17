module Spree
  module Api
    module V1
      class MollieController < BaseController
        def methods
          mollie = Spree::PaymentMethod.find_by_type 'Spree::Gateway::MollieGateway'
          payment_methods = mollie.available_payment_methods

          puts payment_methods

          render json: payment_methods
        end
      end
    end
  end
end