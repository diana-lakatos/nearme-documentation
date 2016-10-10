class WorkflowStep::SignUpWorkflow::ListerOnboarded < WorkflowStep::SignUpWorkflow::BaseStep
  # user:
  #  User object
  #
  def data
    { user: @user }
  end
end
