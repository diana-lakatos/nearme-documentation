class WorkflowStep::SupportWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(message_id)
    @message = Support::TicketMessage.find_by_id(message_id)
  end

  def workflow_type
    'support'
  end

  def enquirer
    @message.ticket.user || User.new(email: @message.email, name: @message.full_name)
  end

  # In support emails lister is an admin who created last reply for the ticket
  def lister
    @message.ticket.messages.map(&:user).compact.reject { |u| u.email == enquirer.email }.first
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
