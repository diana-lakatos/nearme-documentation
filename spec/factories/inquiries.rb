FactoryGirl.define do
  factory :inquiry do
    listing        { FactoryGirl.create(:listing) }
    inquiring_user { FactoryGirl.create(:user) }
    message        "I am asking something important"
  end
end
