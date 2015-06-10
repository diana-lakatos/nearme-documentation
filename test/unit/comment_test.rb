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
end
