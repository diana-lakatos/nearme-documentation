# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :search_notification do
    query 'San Francisco'
    latitude 1.5
    longitude 1.5
    email 'test@test.com'

    trait :with_user do
      user
    end
  end
end
