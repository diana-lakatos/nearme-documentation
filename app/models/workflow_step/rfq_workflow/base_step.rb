class WorkflowStep::RfqWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    true
  end

  def initialize(message_id)
    @message = Support::TicketMessage.find_by_id(message_id)
  end

  def workflow_type
    'request_for_quote'
  end

  def enquirer
    @message.ticket.user || User.new(email: @message.email, name: @message.full_name)
  end

  def lister
    @message.ticket.assigned_to || @message.user
  end

  # message:
  #   Support::TicketMessage object
  # ticket:
  #   Support::Ticket object to which the message belongs
  def data
    { message: @message, ticket: @message.ticket }
  end

  def transactable_type_id
    @message.try(:ticket).try(:target).try(:transactable_type_id)
  end

  def should_be_processed?
    @message.present?
  end

  def workflow_triggered_by
    enquirer
  end
end
