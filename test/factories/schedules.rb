FactoryGirl.define do
  factory :schedule do

    use_simple_schedule false
    schedule '{"start_time":{"time":"2015-06-23T12:00:00.000Z","zone":"Pacific Time (US \u0026 Canada)"},"start_date":{"time":"2015-06-23T12:00:00.000Z","zone":"Pacific Time (US \u0026 Canada)"},"rrules":[{"validations":{"day":[0,1,2,3,4,5,6],"hour_of_day":[12,14,16,18]},"rule_type":"IceCube::WeeklyRule","interval":1,"week_start":0}],"rtimes":[],"extimes":[]}'

    factory :simple_schedule do
      use_simple_schedule true
      sr_start_datetime 1.day.from_now.to_date
      sr_from_hour 6.hours.ago
      sr_to_hour Time.now + 6.hours
      sr_every_hours 2
      sr_days_of_week (0..6).to_a
    end

  end


end
