class WorkflowStep::SignUpWorkflow::CreatedByAdmin < WorkflowStep::SignUpWorkflow::BaseStep
  def initialize(user_id, admin_id)
    @user = User.find(user_id)
    @creator = User.find(admin_id)
  end

  def lister
    @creator
  end

  # new_user:
  #   User object
  # creator:
  #   User object
  def data
    { new_user: @user, creator: @creator }
  end

  def workflow_triggered_by
    @creator
  end
end
