class WorkflowStep::SignUpWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(user_id)
    @user = User.find_by_id(user_id)
  end

  def workflow_type
    'sign_up'
  end

  def enquirer
    @user
  end

  def lister
    @user
  end

  # user:
  #   User object
  def data
    { user: @user }
  end

  def should_be_processed?
    @user.present?
  end

  def workflow_triggered_by
    @user
  end
end
