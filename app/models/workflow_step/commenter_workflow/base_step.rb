# frozen_string_literal: true
class WorkflowStep::CommenterWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(comment_id)
    @comment = Comment.find_by(id: comment_id)
    @commentable = @comment.try(:commentable)
    @user = @comment.try(:creator)
  end

  def enquirer
    @user
  end

  def lister
    raise NotImplementedError, "#{self.class.name} has to define lister method"
  end

  def workflow_type
    'commenter_workflow'
  end

  def should_be_processed?
    return false if enquirer && lister && enquirer.id == lister.id

    @comment.present? && @commentable.present?
  end

  def workflow_triggered_by
    @user
  end
end
