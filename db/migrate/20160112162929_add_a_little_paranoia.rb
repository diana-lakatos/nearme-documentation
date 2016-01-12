class AddALittleParanoia < ActiveRecord::Migration
  def change
    add_column :merchant_accounts, :deleted_at, :datetime
    add_column :payment_gateways, :deleted_at, :datetime
  end
end
