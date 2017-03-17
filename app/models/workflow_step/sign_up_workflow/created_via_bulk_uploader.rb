# frozen_string_literal: true
class WorkflowStep::SignUpWorkflow::CreatedViaBulkUploader < WorkflowStep::SignUpWorkflow::BaseStep
  def initialize(user_id, password)
    @user = User.find(user_id)
    @password = password
  end

  def enquirer
    @user
  end

  def lister
    @user
  end

  # user:
  #   User object
  # user_password:
  #   string
  def data
    { user: @user, user_password: @password }
  end

  def workflow_triggered_by
    nil
  end
end
