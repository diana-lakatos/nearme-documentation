class CreateShippingRules < ActiveRecord::Migration
  def change
    create_table :shipping_rules do |t|
      t.integer :instance_id, index: true
      t.string :name
      t.integer :shipping_profile_id, index: true
      t.integer :price_cents, default: 0
      t.string :processing_time
      t.boolean :is_worldwide, default: true

      t.datetime :deleted_at
      t.timestamps null: false
      t.index [:instance_id, :shipping_profile_id]
    end
  end
end
