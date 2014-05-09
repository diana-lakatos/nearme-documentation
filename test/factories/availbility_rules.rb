FactoryGirl.define do
  factory :availability_rule do
    association :target, factory: :availablity_template
    day 1
    open_hour 9
    open_minute 0
    close_hour 17
    close_minute 0
  end
end
