class CreateInstanceBillingGateways < ActiveRecord::Migration
  def change
    create_table :instance_billing_gateways do |t|
      t.belongs_to :instance
      t.string :billing_gateway
      t.string :currency, default: 'USD'

      t.timestamps
    end
    add_index :instance_billing_gateways, :instance_id
  end
end
