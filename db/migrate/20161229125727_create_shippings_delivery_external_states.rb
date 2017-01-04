class CreateShippingsDeliveryExternalStates < ActiveRecord::Migration
  def change
    create_table :shippings_delivery_external_states do |t|
      t.integer :delivery_id, null: false, index: true
      t.text :body, null: false
      t.integer :instance_id, null: false, index: true
      t.timestamp :deleted_at
      t.timestamps null: false
    end
  end
end
