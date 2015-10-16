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
    #
    assert_difference "ActivityFeedEvent.count", 6 do
      FactoryGirl.create(:comment, commentable: FactoryGirl.create(:activity_feed_event))
    end
  end
end
