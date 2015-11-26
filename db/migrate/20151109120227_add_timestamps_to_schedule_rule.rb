class AddTimestampsToScheduleRule < ActiveRecord::Migration
  def change
    change_table :schedule_rules do |t|
      t.timestamps
    end
  end
end
