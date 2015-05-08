class AddSimpleRulesToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :simple_rules, :text
    add_column :schedules, :sr_start_datetime, :datetime
    add_column :schedules, :sr_from_hour, :time
    add_column :schedules, :sr_to_hour, :time
    add_column :schedules, :sr_every_minutes, :integer
    add_column :schedules, :sr_days_of_week, :text, array: true, default: []
    add_column :schedules, :use_simple_schedule, :boolean, default: true
  end
end
