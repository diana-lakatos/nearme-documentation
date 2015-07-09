class AddTimezoneToLocations < ActiveRecord::Migration
  def up
    add_column :locations, :time_zone, :string

    Location.unscoped.where(deleted_at: nil).find_each do |location|
      timezone = nil
      if location.latitude && location.longitude
        timezone = NearestTimeZone.to(location.latitude, location.longitude)
        timezone = ActiveSupport::TimeZone::MAPPING.select {|k, v| v == timezone }.keys.first
      end
      if timezone.nil? && location.creator
        timezone = location.creator.time_zone
      end
      if timezone
        location.update_column :time_zone, timezone
        location.update_schedules_timezones(true)
      end
    end
  end

  def down
    remove_column :locations, :time_zone, :string
  end
end
