# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rating_hint do
    value %w(1 2 3 4 5).sample
    description Faker::Lorem.sentence
    rating_system
  end
end
