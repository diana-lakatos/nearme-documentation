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

  def data
    { user: @user, user_password: @password }
  end

end

