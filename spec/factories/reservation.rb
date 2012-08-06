FactoryGirl.define do
  factory :reservation do
    association :user
    association :listing
    date { Date.today }
  end
end
