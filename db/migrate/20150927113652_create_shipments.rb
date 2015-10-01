class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.integer :instance_id
      t.integer :reservation_id
      t.boolean :is_insured, default: false
      t.integer :price
      t.string :price_currency
      t.integer :insurance_value
      t.string :insurance_currency
      t.string :label_url
      t.string :tracking_number
      t.string :tracking_url_provider
      t.string :shippo_rate_id
      t.string :shippo_transaction_id
      t.text :shippo_errors
      t.string :direction, default: 'outbound'
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :shipments, [:instance_id, :reservation_id]
  end
end
