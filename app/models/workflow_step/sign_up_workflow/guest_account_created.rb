class WorkflowStep::SignUpWorkflow::GuestAccountCreated < WorkflowStep::SignUpWorkflow::BaseStep

  # user:
  #  User object
  #
  def data
    { user: @user }
  end

end

