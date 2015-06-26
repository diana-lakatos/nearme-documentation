class FixScheduleUseSimpleScheduleFlag < ActiveRecord::Migration
  def up
    Schedule.unscoped.where(use_simple_schedule: true, sr_start_datetime: nil).update_all(use_simple_schedule: false)
  end
end
