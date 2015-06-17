class ChangeInstancePaymentGatewaysTable < ActiveRecord::Migration
  def up
    add_column :instance_payment_gateways, :type, :string
    rename_table :country_instance_payment_gateways, :country_payment_gateways

    connection.execute <<-SQL
      UPDATE instance_payment_gateways
      SET
        type = CASE
                   WHEN payment_gateway_id = 1 THEN 'PaymentGateway::StripePaymentGateway'
                   WHEN payment_gateway_id = 2 THEN 'PaymentGateway::BalancedPaymentGateway'
                   WHEN payment_gateway_id = 3 THEN 'PaymentGateway::PaypalPaymentGateway'
                   WHEN payment_gateway_id = 4 THEN 'PaymentGateway::SagePayPaymentGateway'
                   WHEN payment_gateway_id = 5 THEN 'PaymentGateway::WorldpayPaymentGateway'
                   WHEN payment_gateway_id = 6 THEN 'PaymentGateway::PaystationPaymentGateway'
                   WHEN payment_gateway_id = 7 THEN 'PaymentGateway::AuthorizeNetPaymentGateway'
                   WHEN payment_gateway_id = 8 THEN 'PaymentGateway::OgonePaymentGateway'
                   WHEN payment_gateway_id = 9 THEN 'PaymentGateway::SpreedlyPaymentGateway'
                   WHEN payment_gateway_id = 10 THEN 'PaymentGateway::FetchPaymentGateway'
                   WHEN payment_gateway_id = 11 THEN 'PaymentGateway::BraintreePaymentGateway'
                   WHEN payment_gateway_id = 12 THEN 'PaymentGateway::BraintreeMarketplacePaymentGateway'
                END
    SQL
    drop_table :payment_gateways
    rename_table :instance_payment_gateways, :payment_gateways
    rename_column :country_payment_gateways, :instance_payment_gateway_id, :payment_gateway_id
  end

  def down
    rename_table :payment_gateways, :instance_payment_gateways
    create_table :payment_gateways do |t|
      t.string :name
      t.string :method_name
      t.text :settings
      t.string :active_merchant_class
      t.timestamps
    end
    rename_column :country_payment_gateways, :payment_gateway_id, :instance_payment_gateway_id
    rename_table :country_payment_gateways, :country_instance_payment_gateways
    remove_column :instance_payment_gateways, :type
  end
end
