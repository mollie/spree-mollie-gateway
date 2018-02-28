module Spree
  class MollieTransaction < Spree::Base
    belongs_to :payment_method
    has_many :payment, as: :source

    delegate :name, to: :payment_method

    def actions
      []
    end

    def method_type
      'mollie_transaction'
    end

    def details
      api_key = payment_method.get_preference(:api_key)
      mollie_payment = ::Mollie::Payment.get(payment_id, api_key: api_key)
      mollie_payment.attributes
    end
  end
end