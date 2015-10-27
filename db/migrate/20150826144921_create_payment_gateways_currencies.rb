class CreatePaymentGatewaysCurrencies < ActiveRecord::Migration
  def change
    create_table :payment_gateways_currencies do |t|
      t.integer :currency_id
      t.integer :payment_gateway_id
      t.integer :instance_id
      t.integer :company_id
      t.integer :partner_id
      t.timestamps
    end

    add_index :payment_gateways_currencies, :currency_id
    add_index :payment_gateways_currencies, :payment_gateway_id
    add_index :payment_gateways_currencies, :instance_id
  end
end
