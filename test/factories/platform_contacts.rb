FactoryGirl.define do
  factory :platform_contact do
    name Faker::Name.name
    company "Test Co."
    email Faker::Internet.email
    phone Faker::PhoneNumber.phone_number
    comments "I would like to build a marketplace."
    subscribed true
  end
end

