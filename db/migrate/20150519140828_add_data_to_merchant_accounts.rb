class AddDataToMerchantAccounts < ActiveRecord::Migration
  def change
    add_column :merchant_accounts, :data, :text
  end
end
