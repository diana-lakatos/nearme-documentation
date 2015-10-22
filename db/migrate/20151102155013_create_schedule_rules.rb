class CreateScheduleRules < ActiveRecord::Migration
  def change
    create_table :schedule_rules do |t|
      t.string :run_hours_mode
      t.decimal :every_hours, scale: 2, precision: 8
      t.datetime :time_start
      t.datetime :time_end
      t.datetime :times, array: true, default: []
      t.string :run_dates_mode
      t.integer :week_days, array: true, default: []
      t.datetime :dates, array: true, default: []
      t.datetime :date_start
      t.datetime :date_end
      t.integer :instance_id
      t.integer :schedule_id
      t.index [:instance_id, :schedule_id]
    end
  end
end
