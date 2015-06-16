class WorkflowStep::SupportWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize(message_id)
    @message = Support::TicketMessage.find_by_id(message_id)
  end

  def workflow_type
    'support'
  end

  def enquirer
    @message.user || User.new(email: @message.email, name: @message.full_name)
  end

  def lister
    @message.ticket.assigned_to || User.new(email: @message.email, name: @message.full_name)
  end

  # message:
  #   Support::TicketMessage object
  # ticket:
  #   Support::Ticket object to which the message belongs
  def data
    { message: @message, ticket: @message.ticket }
  end

  def should_be_processed?
    @message.present?
  end

end
