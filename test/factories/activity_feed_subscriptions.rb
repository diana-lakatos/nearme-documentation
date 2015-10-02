FactoryGirl.define do
  factory :activity_feed_subscription do
    followed { FactoryGirl.create(:user) }
    follower { FactoryGirl.create(:user) }
  end
end
