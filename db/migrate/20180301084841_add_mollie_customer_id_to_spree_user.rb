class AddMollieCustomerIdToSpreeUser < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :mollie_customer_id, :string
  end
end
