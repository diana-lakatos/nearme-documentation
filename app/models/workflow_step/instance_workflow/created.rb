class WorkflowStep::InstanceWorkflow::Created < WorkflowStep::InstanceWorkflow::BaseStep
  def initialize(instance_id, user_id, password)
    super(instance_id, user_id)
    @user_password = password
  end

  def data
    super.merge(user_password: @user_password)
  end
end

