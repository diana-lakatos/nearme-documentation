class AddVerificationFailedToMerchantAccounts < ActiveRecord::Migration
  def change
    add_column :merchant_accounts, :verified_at, :datetime
  end
end
