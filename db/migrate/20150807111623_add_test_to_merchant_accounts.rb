class AddTestToMerchantAccounts < ActiveRecord::Migration
  def change
    add_column :merchant_accounts, :test, :boolean, default: false
  end
end
