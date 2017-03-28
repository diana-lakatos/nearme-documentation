require 'test_helper'

class Api::V3::ActivityFeedEventsControllerTest < ActionController::TestCase
  setup do
    PlatformContext.current.instance.update_attribute(:is_community, true)
    @user = FactoryGirl.create(:user)
    set_authentication_header(@user)
  end

  context '#index' do
    should 'get json' do
      FactoryGirl.create(:activity_feed_subscription, follower: @user, followed: @user)

      get :index, format: :json

      assert_equal(
        %w(id event followed-id followed-type affected-objects-identifiers event-source-id event-source-type created-at),
        JSON.parse(response.body).dig('data', 0, 'attributes').keys
      )
    end
  end
end
