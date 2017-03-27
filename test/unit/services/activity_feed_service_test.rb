require 'test_helper'

class ActivityFeedServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  def events
    ActivityFeedService.new(@user).events
  end

  should '#events' do
    # The number of events on follow returned by the ActivityFeedService should stay 0
    # as those events are hidden by default
    followed1 = create(:user)
    followed2 = create(:user)
    follower1 = create(:user)
    project1  = create(:project)

    assert_equal 0, events.count

    # Following actions
    #
    @user.feed_follow!(followed1)
    assert_equal 0, events.count

    @user.feed_follow!(followed2)
    assert_equal 0, events.count

    # Even if someone follows an user, we don't want to
    # display on user's feed.
    #
    follower1.feed_follow!(@user)
    assert_equal 0, events.count

    # User can also follow projects here we jump to five
    # because there's the project creation event and the action of
    # following the project.
    #
    # The last - first in chronology - event should be user_created_project
    # because the project was created before this user following anyone
    #
    # The first - last in chronology - event should be user following project
    # because he followed everyone afterwards.
    #

    @user.feed_follow!(project1)

    assert_equal 2, events.count

    # You can unfollow users - and events are deleted from your
    # timeline.
    #
    @user.feed_unfollow!(followed1)
    assert_equal 2, events.count

    @user.feed_unfollow!(followed2)
    assert_equal 2, events.count
  end

  context 'instance methods' do
    setup do
      @feed = ActivityFeedService.new(@user)
    end

    should '#owner_id' do
      assert @user.id == @feed.owner_id
    end

    should '#owner_type' do
      assert @user.class.name == @feed.owner_type
    end
  end

  context 'class methods' do
    should '.create_event' do
      followed = create(:user)

      # It should create a new event.
      #
      assert_difference 'ActivityFeedEvent.count' do
        ActivityFeedService.create_event(
          :user_followed_user,
          followed,
          [followed],
          @user
        )
      end
    end
  end
end
