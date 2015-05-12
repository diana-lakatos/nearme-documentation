class ReplaceVerifiedAtWithStateInMerchantAccounts < ActiveRecord::Migration
  def change
    remove_column :merchant_accounts, :verified_at, :datetime
    add_column :merchant_accounts, :state, :string, default: 'pending'
  end
end
