class ChangeUnavailablePeriodEnabledInSchedules < ActiveRecord::Migration
  def up
    change_column :schedules, :unavailable_period_enabled, :boolean, default: false
    PlatformContext.clear_current
    Schedule.unscoped.update_all("unavailable_period_enabled = EXISTS(SELECT 1 FROM schedule_exception_rules where schedule_id = schedules.id LIMIT 1)")
  end

  def down
    change_column :schedules, :unavailable_period_enabled, :boolean, default: true
  end
end
