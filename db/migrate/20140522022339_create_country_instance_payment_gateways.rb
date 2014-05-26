class CreateCountryInstancePaymentGateways < ActiveRecord::Migration
  def change
    create_table :country_instance_payment_gateways do |t|
      t.string :country_alpha2_code
      t.integer :instance_payment_gateway_id
      t.integer :instance_id

      t.timestamps
    end
  end
end
