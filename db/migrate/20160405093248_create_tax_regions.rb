class CreateTaxRegions < ActiveRecord::Migration
  def change
    create_table :tax_regions do |t|
      t.datetime :deleted_at
      t.integer :instance_id, index: true
      t.integer :country_id, index: true
      t.integer :state_id, index: true

      t.timestamps null: false
    end
  end
end
