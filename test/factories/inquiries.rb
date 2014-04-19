FactoryGirl.define do
  factory :inquiry do
    listing        { FactoryGirl.build(:transactable) }
    inquiring_user { FactoryGirl.build(:user) }
    message        "I am asking something important"
  end
end
