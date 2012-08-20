FactoryGirl.define do
  factory :authentication do
    association :user
    provider 'twitter'
    uid 'ima_donkey'
  end
end
