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

  def data
    { user: @user }
  end

end
