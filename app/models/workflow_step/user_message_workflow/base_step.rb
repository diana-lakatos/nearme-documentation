class WorkflowStep::UserMessageWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize(user_message_id)
    @user_message = UserMessage.find_by_id(user_message_id)
  end

  def workflow_type
    'user_message'
  end

  def enquirer
    @user_message.recipient
  end

  def lister
    @user_message.recipient
  end

  def data
    { user_message: @user_message, user: @user_message.recipient }
  end

end
