class CreateSpreeMolliePaymentSources < SpreeExtension::Migration[4.2]
  def change
    create_table :spree_mollie_payment_sources do |t|
      t.string :payment_id
      t.string :payment_method_name
      t.string :issuer
      t.string :status
      t.string :payment_url
      t.integer :payment_method_id
      t.integer :user_id
    end
  end
end
