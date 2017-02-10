FactoryGirl.define do
  factory :activity_feed_event do
    event 'user_followed_user'
    followed { FactoryGirl.create(:project) }
    event_source { FactoryGirl.create(:project) }

    factory :activity_feed_event_user do
      followed { FactoryGirl.create(:user) }
    end
  end
end
