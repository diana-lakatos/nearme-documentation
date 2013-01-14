# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :charge do
    reservation_id 1
    success false
    response "MyText"
    amount 1
  end
end
