FactoryGirl.define do
  factory :saved_search do
    title { Faker::Lorem.words([1, 2, 3, 4].sample).join(' ') }
    user
    query 'change this'
  end
end
