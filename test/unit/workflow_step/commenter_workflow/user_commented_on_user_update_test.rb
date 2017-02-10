require 'test_helper'

class WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdateTest < ActiveSupport::TestCase
  context 'with comment' do
    setup do
      @comment = FactoryGirl.create(:comment, commentable: FactoryGirl.create(:activity_feed_event_user))
    end

    should 'work' do
      workflow = WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate.new(@comment.id)
      assert_not_nil workflow.data
    end
  end
end
