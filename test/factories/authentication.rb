FactoryGirl.define do
  factory :authentication do
    association :user
    provider 'twitter'
    sequence(:uid) { |n| "uid #{n}" }
  end
end
