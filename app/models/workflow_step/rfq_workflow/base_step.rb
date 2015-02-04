class WorkflowStep::RfqWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize(message_id)
    @message = Support::TicketMessage.find_by_id(message_id)
  end

  def workflow_type
    'request_for_quote'
  end

  def enquirer
    @message.user || User.new(email: @message.email, name: @message.full_name)
  end

  def lister
    @message.ticket.assigned_to || User.new(email: @message.email, name: @message.full_name)
  end

  def data
    { message: @message, ticket: @message.ticket }
  end

  def transactable_type_id
    @message.try(:ticket).try(:target).try(:transactable_type_id)
  end

end
