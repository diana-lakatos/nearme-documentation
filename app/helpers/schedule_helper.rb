module ScheduleHelper
  def build_schedule(scheduable)
    schedule = scheduable.build_schedule(schedule: scheduable.transactable_type_action_type.schedule.try(:schedule).try(:to_hash).try(:to_json))
    Time.use_zone('UTC') do
      scheduable.transactable_type_action_type.schedule.try(:schedule_rules).try(:each) do |sr|
        schedule.schedule_rules.build(run_hours_mode: sr.run_hours_mode, every_hours: sr.every_hours,
                                      time_start: sr.time_start, time_end: sr.time_end,
                                      times: sr.times.map { |t| Time.zone.local_to_utc(t).in_time_zone }, run_dates_mode: sr.run_dates_mode,
                                      week_days: sr.week_days, dates: sr.dates, date_start: sr.date_start, date_end: sr.date_end
                                     )
      end
    end
    schedule
  end
end
