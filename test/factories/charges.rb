FactoryGirl.define do
  factory :charge do
    association :user
    success true
  end
end
