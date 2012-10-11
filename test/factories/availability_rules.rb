# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :availability_rule do
    target_type "MyString"
    target_id 1
    day 1
    open_hour 1
    open_minute 1
    close_hour 1
    close_minute 1
  end
end
