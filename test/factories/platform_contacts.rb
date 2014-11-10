FactoryGirl.define do
  factory :platform_contact do
    name Faker::Name.name
    company Faker::Company.name
    email Faker::Internet.email
    phone Faker::PhoneNumber.phone_number
    location Faker::Address.city
    comments Faker::Lorem.sentence
    subscribed true
  end
end

