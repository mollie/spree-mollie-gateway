Spree::Api::V1::ShipmentsController.class_eval do
  def ship
    @shipment.ship! unless @shipment.shipped?
    respond_with(@shipment, default_template: :show)
  end
end
