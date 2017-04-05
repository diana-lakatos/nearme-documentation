require 'test_helper'

class ActivityFeedControllerTest < ActionController::TestCase
  setup do
    PlatformContext.current.instance.update_attribute(:is_community, true)
    @user = FactoryGirl.create(:user)
    sign_in @user
    @another_user = FactoryGirl.create(:user)
  end

  should 'POST #create' do
    assert_difference 'ActivityFeedSubscription.count' do
      post :follow, id: @another_user.id, type: 'User', format: :js
    end
  end

  should 'DELETE #destroy' do
    FactoryGirl.create(:activity_feed_subscription, follower: @user, followed: @another_user)
    assert_difference 'ActivityFeedSubscription.count', -1 do
      delete :unfollow, id: @another_user.id, type: 'User', format: :js
    end
  end

  should 'get #activity_feed' do
    xhr :get, :activity_feed, id: @another_user.id, type: 'User', page: 1, format: :js

    assert_response :success
  end
end
