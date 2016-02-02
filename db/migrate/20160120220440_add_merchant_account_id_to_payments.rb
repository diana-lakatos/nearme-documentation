class AddMerchantAccountIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :merchant_account_id, :integer, index: true
  end
end
