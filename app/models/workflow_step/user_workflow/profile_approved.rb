class WorkflowStep::UserWorkflow::ProfileApproved < WorkflowStep::UserWorkflow::BaseStep
  def initialize(user_id)
    @user = User.find(user_id)
  end

  def enquirer
    @user
  end

  def lister
    @user
  end

  # user who was approved
  #   User object
  def data
    { user: @user }
  end
end
