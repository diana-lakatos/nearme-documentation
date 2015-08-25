class CreatePaymentGatewaysCountries < ActiveRecord::Migration
  def change
    create_table :payment_gateways_countries do |t|
      t.integer :country_id
      t.integer :payment_gateway_id
      t.integer :instance_id
      t.integer :company_id
      t.integer :partner_id
      t.timestamps
    end

    add_index :payment_gateways_countries, :country_id
    add_index :payment_gateways_countries, :payment_gateway_id
    add_index :payment_gateways_countries, :instance_id
  end
end
