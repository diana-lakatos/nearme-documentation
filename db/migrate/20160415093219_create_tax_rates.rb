class CreateTaxRates < ActiveRecord::Migration
  def change
    create_table :tax_rates do |t|
      t.datetime :deleted_at
      t.integer :instance_id, index: true
      t.integer :state_id, index: true
      t.integer :value
      t.boolean :included_in_price, default: true
      t.string :name
      t.string :admin_name
      t.string :calculate_with
      t.integer :tax_region_id, index: true
      t.boolean :default, default: false

      t.timestamps null: false
    end
  end
end
