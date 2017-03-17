# frozen_string_literal: true
class WorkflowStep::UserWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(user_id)
    @user = User.find(user_id)
  end

  def workflow_type
    'user'
  end

  def enquirer
    @user
  end

  # user:
  #   User object
  def data
    { user: @user }
  end

  def workflow_triggered_by
    @user
  end
end
