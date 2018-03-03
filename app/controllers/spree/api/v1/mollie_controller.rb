class Spree::Api::V1::MollieController < Spree::Api::BaseController
  before_action :set_payment_method, only: [:methods]

  def methods
    render json: @payment_method.available_payment_methods
  end

  private
  def set_payment_method
    @payment_method = Spree::PaymentMethod.find_by_type('Spree::Gateway::MollieGateway')
  end
end