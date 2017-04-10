# frozen_string_literal: true
FactoryGirl.define do
  factory :transactable_collaborator do
    association :user
    association :transactable
    approved_by_owner_at nil

    factory :approved_transactable_collaborator do
      approved_by_owner_at Time.now
      approved_by_user_at Time.now
    end
  end
end
