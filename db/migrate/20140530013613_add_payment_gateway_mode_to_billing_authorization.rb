class AddPaymentGatewayModeToBillingAuthorization < ActiveRecord::Migration
  def change
    add_column :billing_authorizations, :payment_gateway_mode, :string
  end
end
