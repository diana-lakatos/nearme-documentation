class AddExternalIdToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :external_id, :string
    add_column :payments, :external_id, :string
    add_column :merchant_accounts, :external_id, :string

    Payment.reset_column_information
    Payment.update_all('external_id = external_transaction_id')
    MerchantAccount.update_all('external_id = internal_payment_gateway_account_id')
  end
end
