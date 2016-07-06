FactoryGirl.define do
  factory :transactable_collaborator do
    association :user
    association :transactable
    approved_by_owner_at nil
  end
end
