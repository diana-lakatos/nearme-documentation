class WorkflowStep::UserMessageWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    true
  end

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

  # user_message
  #   UserMessage object
  # user
  #   User object
  def data
    { user_message: @user_message, user: @user_message.recipient }
  end

  def transactable_type_id
    @user_message.thread_context.try(:transactable_type_id)
  end

  def should_be_processed?
    @user_message.present?
  end

  def workflow_triggered_by
    @user_message.author
  end
end
