require 'test_helper'

class ActivityFeedSubscriptionTest < ActiveSupport::TestCase
  setup do
    @subscription = FactoryGirl.build(:activity_feed_subscription)
  end

  context 'included modules' do
    %w(
      PlatformContext::DefaultScoper
      PlatformContext::ForeignKeysAssigner
    ).each do |_module|
      should "include #{_module}" do
        assert ActivityFeedEvent.included_modules.include?(_module.constantize)
      end
    end
  end

  context 'associations' do
    should belong_to(:followed)
    should belong_to(:follower)
  end

  context 'scopes' do
    should '.find_subscription' do
      @subscription.save
      follower = @subscription.follower
      followed = @subscription.followed
      assert_includes ActivityFeedSubscription.find_subscription(follower, followed), @subscription
    end
  end

  context 'callbacks' do
    setup do
      @follower = create(:user)
      @followed = create(:user)
    end

    should '#set_followed_identifier before_save' do
      @subscription.save
      assert_equal ActivityFeedService::Helpers.object_identifier_for(@subscription.followed), @subscription.followed_identifier
    end

    should '#create_feed_event after_commit on: :create' do
      assert_difference 'ActivityFeedEvent.count' do
        create(:activity_feed_subscription)
      end
    end

    should '#increase_counters after_commit on: :create' do
      following = @follower.following_count
      followers = @followed.followers_count

      create(:activity_feed_subscription, followed: @followed, follower: @follower)

      assert following + 1, @follower.reload.following_count
      assert followers + 1, @followed.reload.followers_count
    end

    should '#decrease_counters after_commit on: :destroy' do
      following = @follower.following_count
      followers = @followed.followers_count

      create(:activity_feed_subscription, followed: @followed, follower: @follower)

      assert following - 1, @follower.reload.following_count
      assert followers - 1, @followed.reload.followers_count
    end
  end

  context 'class methods' do
    %w(followed follower).each do |attribute|
      should ".#{attribute}_as_objects" do
        3.times { FactoryGirl.create(:activity_feed_subscription, attribute.to_sym => FactoryGirl.create(:user)) }
        collection = ActivityFeedSubscription.all.map(&attribute.to_sym)
        assert_equal 3, collection.count
        assert_equal User, collection.uniq.first.class
      end
    end
  end
end
