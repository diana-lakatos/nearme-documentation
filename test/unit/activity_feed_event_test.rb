require 'test_helper'

class ActivityFeedEventTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @activity_feed_event = build(:activity_feed_event)
  end

  context "included modules" do
    %w(
      PlatformContext::DefaultScoper
      PlatformContext::ForeignKeysAssigner
    ).each do |_module|
      should "include #{_module}" do
        assert ActivityFeedEvent.included_modules.include?(_module.constantize)
      end
    end
  end

  context "associations" do
    should belong_to(:followed)
    should belong_to(:event_source)
  end

  context "callbacks" do
    should "#update_affected_objects before_create" do
      identifier = ActivityFeedService::Helpers.object_identifier_for(@user)
      event = build(:activity_feed_event)
      event.affected_objects = [@user]
      event.save
      assert_includes event.affected_objects_identifiers, identifier
    end
  end

  context "instance methods" do
    should "#name" do
      @user.first_name = "test"
      @activity_feed_event.followed = @user
      assert_equal @activity_feed_event.followed.name, @activity_feed_event.name
    end

    should "#description" do
      followed = create(:project, description: "followed")
      event_source1 = create(:project, description: "evt_source1")
      event_source2 = create(:user_status_update, text: "evt_source2")

      @activity_feed_event.followed = followed
      assert_equal followed.description, @activity_feed_event.description

      @activity_feed_event.followed = nil
      @activity_feed_event.event_source = event_source1
      assert_equal event_source1.description, @activity_feed_event.description

      @activity_feed_event.event_source = event_source2
      assert_equal "&#147;#{event_source2.text}&#148;".html_safe, @activity_feed_event.description

    end

    should "#event=" do
      assert_not_equal "my_custom_event", @activity_feed_event.event
      @activity_feed_event.event = :my_custom_event
      assert_equal "my_custom_event", @activity_feed_event.event
    end
  end
end
