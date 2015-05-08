FactoryGirl.define do
  factory :schedule do

    use_simple_schedule false

    initialize_with do
      new(
        schedule: '{"start_time":"2015-03-24T06:05:00.000Z","end_time":"2015-03-26T06:53:00.000Z","rrules":[{"rule_type":"IceCube::WeeklyRule","interval":1,"validations":{}}]}'
      )
    end

  end
end
