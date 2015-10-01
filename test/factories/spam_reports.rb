FactoryGirl.define do
  factory :spam_report do
    association :user, factory: :user
    association :spamable, factory: :comment
  end
end
