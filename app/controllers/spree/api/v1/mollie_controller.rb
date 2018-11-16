module Spree
  module Api
    module V1
      class MollieController < BaseController
        def methods
          mollie = Spree::PaymentMethod.find_by_type 'Spree::Gateway::MollieGateway'
          payment_methods = mollie.available_methods(methods_params).map(&:attributes)

          render json: payment_methods
        end

        private

        def methods_params
          params.permit(amount: %i[currency value])
        end
      end
    end
  end
end
