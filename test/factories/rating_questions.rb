# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rating_question do
    text Faker::Lorem.sentence
    rating_system
  end
end
