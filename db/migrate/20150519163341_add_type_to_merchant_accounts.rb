class AddTypeToMerchantAccounts < ActiveRecord::Migration
  def change
    add_column :merchant_accounts, :type, :string
  end
end
