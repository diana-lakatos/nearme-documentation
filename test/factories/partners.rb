# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :partner do
    name "MyString"
    service_fee_percent "10.00"
  end
end
