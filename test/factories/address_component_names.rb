# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :address_component_name do
    long_name "MyString"
    short_name "MyString"
    location ""
  end
end
