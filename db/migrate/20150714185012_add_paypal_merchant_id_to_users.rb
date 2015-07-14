class AddPaypalMerchantIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :paypal_merchant_id, :string
  end
end
