FactoryGirl.define do
  factory :transactable_topic do
    association :topic
    association :transactable
  end
end
