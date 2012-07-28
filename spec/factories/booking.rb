FactoryGirl.define do
  factory :booking do
    association :user
    association :workplace
    date { Date.today }
  end
end
