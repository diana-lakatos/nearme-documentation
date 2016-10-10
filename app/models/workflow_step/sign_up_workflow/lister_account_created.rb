class WorkflowStep::SignUpWorkflow::ListerAccountCreated < WorkflowStep::SignUpWorkflow::BaseStep
  # user:
  #  User object
  # location:
  #  Location object (user location)
  def data
    { user: @user, location: @user.locations.first }
  end
end
