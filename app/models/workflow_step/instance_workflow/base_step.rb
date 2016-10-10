class WorkflowStep::InstanceWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(instance_id, user_id)
    @instance = Instance.find_by_id(instance_id)
    @user = User.find_by_id(user_id)
  end

  def workflow_type
    'instance'
  end

  def enquirer
    @user
  end

  def lister
    @user
  end

  def data
    { instance: @instance, user: @user }
  end
end
