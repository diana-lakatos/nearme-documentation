class AddMerchantAccountIdToBillingAuthorizations < ActiveRecord::Migration
  def change
    add_column :billing_authorizations, :merchant_account_id, :integer
  end
end
