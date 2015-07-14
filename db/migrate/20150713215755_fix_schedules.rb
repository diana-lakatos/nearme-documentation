class FixSchedules < ActiveRecord::Migration

  def up
    Schedule.unscoped.where.not(sr_start_datetime: nil).where(deleted_at: nil, use_simple_schedule: false).find_each do |schedule|
      if version = schedule.previous_version
        if version.schedule.start_time != version.sr_start_datetime
          schedule.schedule.start_time = version.schedule.start_time
          schedule.save!
        end
      end
    end
  end

end
