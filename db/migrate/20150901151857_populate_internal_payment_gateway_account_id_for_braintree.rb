class PopulateInternalPaymentGatewayAccountIdForBraintree < ActiveRecord::Migration
  def up
    MerchantAccount::BraintreeMarketplaceMerchantAccount.where(internal_payment_gateway_account_id: nil).each { |ma| ma.update_column(:internal_payment_gateway_account_id, ma.custom_braintree_id) }
  end

  def down
  end
end
