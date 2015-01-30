class WorkflowStep::SignUpWorkflow::AccountCreated < WorkflowStep::SignUpWorkflow::BaseStep

  def data
    { user: @user, location: @user.locations.first }
  end

end

