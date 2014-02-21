FactoryGirl.define do
  factory :platform_demo_request do
    name Faker::Name.name
    email Faker::Internet.email
    company Faker::Company.name
    phone Faker::PhoneNumber.phone_number
    comments "How do I learn more about the Near Me platform?"
    subscribed true
  end
end
