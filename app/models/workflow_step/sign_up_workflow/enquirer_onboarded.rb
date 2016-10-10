class WorkflowStep::SignUpWorkflow::EnquirerOnboarded < WorkflowStep::SignUpWorkflow::BaseStep
  # user:
  #  User object
  #
  def data
    { user: @user }
  end
end
