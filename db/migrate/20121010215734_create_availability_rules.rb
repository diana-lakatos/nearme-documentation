class CreateAvailabilityRules < ActiveRecord::Migration
  def change
    create_table :availability_rules do |t|
      t.string :target_type
      t.integer :target_id
      t.integer :day
      t.integer :open_hour
      t.integer :open_minute
      t.integer :close_hour
      t.integer :close_minute

      t.timestamps
    end

    add_index :availability_rules, [:target_type, :target_id]
  end
end
