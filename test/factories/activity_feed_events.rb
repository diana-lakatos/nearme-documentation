FactoryGirl.define do
  factory :activity_feed_event do
    event "user_followed_user"
    followed { FactoryGirl.create(:transactable) }
    event_source { FactoryGirl.create(:transactable) }
  end
end

