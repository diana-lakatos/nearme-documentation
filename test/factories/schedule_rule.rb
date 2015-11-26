FactoryGirl.define do
  factory :schedule_rule do
    schedule
    run_hours_mode 'recurring'
    every_hours '3.25'
    time_start { "9:45".to_time.in_time_zone }
    time_end { "19:30".to_time }
    times { ["10:25".to_time.in_time_zone, "14:15".to_time.in_time_zone, "19:01".to_time.in_time_zone] }

    run_dates_mode "specific"
    week_days { [0, 1, 5] }
    dates { [Time.zone.now.beginning_of_day, Time.zone.now.beginning_of_day + 3.days, Time.zone.now.beginning_of_day + 7.days] }
    date_start { Time.zone.now.beginning_of_day + 3.days }
    date_end { Time.zone.now.beginning_of_day + 5.days }

    trait :recurring_hours_mode do
      run_hours_mode 'recurring'
    end

    trait :specific_hours_mode do
      run_hours_mode 'specific'
    end

    trait :recurring_dates_mode do
      run_dates_mode 'recurring'
    end

    trait :specific_dates_mode do
      run_dates_mode 'specific'
    end

    trait :date_range_dates_mode do
      run_dates_mode 'range'
    end

    trait :future_years do
      dates { [Time.zone.now.beginning_of_day + 2.years, Time.zone.now.beginning_of_day + 3.days + 2.years, Time.zone.now.beginning_of_day + 7.days + 2.years] }
      date_start { Time.zone.now.beginning_of_day + 3.days + 2.years}
      date_end { Time.zone.now.beginning_of_day + 5.days + 2.years}
    end

  end

end
