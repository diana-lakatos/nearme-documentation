FactoryGirl.define do
  factory :project_topic do
    association :topic
    association :project
  end
end
