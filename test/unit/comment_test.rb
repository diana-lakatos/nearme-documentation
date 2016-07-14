require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  should belong_to(:commentable)

  setup do
    @project_creator = FactoryGirl.create :user
    @comment_creator = FactoryGirl.create :user
    @guest = FactoryGirl.create :user
    @project = FactoryGirl.create :project, creator: @project_creator
    @comment = FactoryGirl.create :comment, commentable: @project, creator: @comment_creator
  end

  should "not allow to remove to stranger" do
    assert @comment.can_remove?(@project_creator)
    assert @comment.can_remove?(@comment_creator)
    assert_not @comment.can_remove?(@guest)
  end

  should "add activity feed event if commentable is project" do
    project = FactoryGirl.create(:project)
    assert_difference "ActivityFeedEvent.count" do
      FactoryGirl.create(:comment, commentable: project)
    end
  end

  should "add activity feed event if commentable is project" do
    # events:
    # 1) Project created for event_source
    # 2) Project created for followed
    # 3) User commented on activity feed event
    # 4 and 5) Topics created for projects above.
    # 6 and 7) Link / Photo events
    # 8) For user.
    #
    assert_difference "ActivityFeedEvent.count", 8 do
      FactoryGirl.create(:comment, commentable: FactoryGirl.create(:activity_feed_event))
    end
  end

  test '#group_activity_commented?' do
    @group = create(:group)
    @event = create(:activity_feed_event, event: 'user_commented', followed: @group)
    @comment = build(:comment, commentable: @event, creator: @user)

    assert @comment.send(:group_activity_commented?)
  end

  test 'create group activities comment when user is a member' do
    @user = create(:user)
    @group = create(:group)
    @event = create(:activity_feed_event, event: 'user_commented', followed: @group)
    @comment = build(:comment, commentable: @event, creator: @user)
    @user.stubs(:is_member_of?).with(@group).returns(true)

    @comment.valid?

    assert_not @comment.errors.include?(:membership)
  end

  test 'does not create group activities comment when user is not a member' do
    @user = create(:user)
    @group = create(:group)
    @event = create(:activity_feed_event, event: 'user_commented', followed: @group)
    @comment = build(:comment, commentable: @event, creator: @user)
    @user.stubs(:is_member_of?).with(@group).returns(false)

    @comment.valid?

    assert @comment.errors.include?(:membership)
  end

end
