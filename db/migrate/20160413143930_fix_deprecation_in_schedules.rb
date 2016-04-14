class FixDeprecationInSchedules < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      Schedule.find_each do |schedule|
        schedule_hash = JSON.parse(schedule[:schedule])
        schedule_hash['start_time'] = schedule_hash.delete('start_date')
        schedule.update_column :schedule, schedule_hash.to_json
      end
    end
  end
end
