class CreateShippingsShippingProviders < ActiveRecord::Migration
  def change
    create_table :shippings_shipping_providers do |t|
      t.integer :instance_id, null: false
      t.string :shipping_provider_name, null: false

      t.string :encrypted_live_settings
      t.string :encrypted_test_settings

      t.timestamps null: false
    end
  end
end
