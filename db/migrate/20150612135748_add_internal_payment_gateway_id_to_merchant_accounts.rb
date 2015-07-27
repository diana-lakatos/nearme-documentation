class AddInternalPaymentGatewayIdToMerchantAccounts < ActiveRecord::Migration
  def change
    add_column :merchant_accounts, :internal_payment_gateway_account_id, :string, index: true
  end
end
