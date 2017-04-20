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

  context 'with deleted commnet' do
    setup do
      @comment = FactoryGirl.create(:comment, commentable: FactoryGirl.create(:activity_feed_event_user))
      @comment.destroy
    end

    should 'invoke with without error' do
      workflow = WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate.new(@comment.id)

      assert_nil workflow.invoke!(FactoryGirl.create(:user))
    end
    
    should 'not be processed' do
      workflow = WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate.new(@comment.id)

      refute workflow.should_be_processed?
    end
  end
end
