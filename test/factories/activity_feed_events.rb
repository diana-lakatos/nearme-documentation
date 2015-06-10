FactoryGirl.define do
  factory :activity_feed_event do
    event "user_followed_user"
    followed { FactoryGirl.create(:user) }
    event_source { FactoryGirl.create(:project) }
  end
end
