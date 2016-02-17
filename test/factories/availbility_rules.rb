FactoryGirl.define do
  factory :availability_rule do
    association :target, factory: :availability_template
    open_hour 9
    open_minute 0
    close_hour 17
    close_minute 0
    days [1]

    trait :always_open do
      open_hour 0
      open_minute 0
      close_hour 23
      close_minute 59
      days (0..6).to_a
    end
  end
end
