Spree::User.class_eval do
  after_create :create_mollie_customer

  def create_mollie_customer
    mollie_gateway = Spree::PaymentMethod.find_by_type('Spree::Gateway::MollieGateway')
    mollie_customer = mollie_gateway.create_customer(self)
    update mollie_customer_id: mollie_customer.id
  end
end