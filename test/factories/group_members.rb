FactoryGirl.define do
  factory :group_member do
    approved_by_owner_at { Time.zone.now }
    approved_by_user_at { Time.zone.now }

    association :user
    association :group, strategy: :build

    factory :group_member_pending do
      approved_by_owner_at nil
      approved_by_user_at nil
    end
  end
end
