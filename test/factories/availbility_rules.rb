FactoryGirl.define do
  factory :availability_rule do
    association :target, factory: :availability_template
    open_hour 9
    open_minute 0
    close_hour 17
    close_minute 0
    days [1]
  end
end
