class CreateScheduleExceptionRules < ActiveRecord::Migration
  def change
    create_table :schedule_exception_rules do |t|
      t.string :label
      t.datetime :duration_range_start
      t.datetime :duration_range_end, index: true
      t.integer :schedule_id
      t.integer :instance_id
      t.timestamps
    end
    add_index :schedule_exception_rules, [:instance_id, :schedule_id]
  end
end

