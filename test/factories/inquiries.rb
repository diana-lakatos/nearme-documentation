FactoryGirl.define do
  factory :inquiry do
    listing        { FactoryGirl.build(:listing) }
    inquiring_user { FactoryGirl.build(:user) }
    message        "I am asking something important"
  end
end
