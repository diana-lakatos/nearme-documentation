class WorkflowStep::SignUpWorkflow::EnquirerAccountCreated < WorkflowStep::SignUpWorkflow::BaseStep
  # user:
  #  User object
  #
  def data
    { user: @user }
  end

end
