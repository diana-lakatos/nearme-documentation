class CreateImpressions < ActiveRecord::Migration
  def change
    create_table :impressions do |t|
      t.integer :impressionable_id
      t.string :impressionable_type
      t.string :ip_address

      t.timestamps
    end

    add_index :impressions, [:impressionable_type, :impressionable_id], :unique => false
  end
end
