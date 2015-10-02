FactoryGirl.define do
  factory :project_collaborator do
    association :user
    association :project
    approved_at nil
  end
end
