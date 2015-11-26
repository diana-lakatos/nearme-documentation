class AddUnavailablePeriodEnabledToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :unavailable_period_enabled, :boolean, default: true
  end
end
