class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.text :schedule
      t.string :scheduable_type
      t.integer :scheduable_id
      t.integer :instance_id
      t.datetime :deleted_at
      t.boolean :exception, default: false
      t.timestamps
    end
    add_index :schedules, [:instance_id, :scheduable_id, :scheduable_type], name: 'index_schedules_scheduable'
  end
end
