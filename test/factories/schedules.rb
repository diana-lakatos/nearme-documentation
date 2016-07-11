FactoryGirl.define do
  factory :schedule do

    schedule '{"start_time":{"time":"2015-06-23T12:00:00.000Z","zone":"Pacific Time (US \u0026 Canada)"},"rrules":[{"validations":{"day":[0,1,2,3,4,5,6],"hour_of_day":[12,14,16,18]},"rule_type":"IceCube::WeeklyRule","interval":1,"week_start":0}],"rtimes":[],"extimes":[]}'
  end


end
