class CreateShippingAddresses < ActiveRecord::Migration
  def change
    create_table :shipping_addresses do |t|
      t.integer :instance_id
      t.integer :shipment_id
      t.integer :user_id
      t.string :shippo_id
      t.string :name
      t.string :company
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :phone
      t.string :email
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :shipping_addresses, [:instance_id, :shipment_id]
    add_index :shipping_addresses, [:instance_id, :user_id]
  end
end
