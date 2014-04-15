class Support::TicketDrop < BaseDrop
  attr_reader :ticket

  def initialize(ticket)
    @ticket = ticket
  end

  def first_message
    ticket.first_message
  end

  def created_at
    ticket.created_at.to_s
  end

  def url
    routes.support_ticket_url(ticket)
  end

  def messages_count
    messages.count
  end

  def admin_url
    routes.instance_admin_manage_support_ticket_url(ticket)
  end

  def id
    ticket.id
  end

  def messages
    ticket.messages.tap(&:shift)
  end
end
