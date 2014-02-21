FactoryGirl.define do
  factory :platform_contact do
    name Faker::Name.name
    email Faker::Internet.email
    subject "I have a question."
    comments "How do I learn more about the Near Me platform?"
    subscribed true
  end
end

