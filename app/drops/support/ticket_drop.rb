class Support::TicketDrop < BaseDrop

  attr_reader :ticket

  def initialize(ticket)
    @ticket = ticket
  end

  # first message for this support ticket thread
  def first_message
    ticket.first_message
  end

  # date/time when this ticket was created
  def created_at
    ticket.created_at.to_s
  end

  # url to this user's requests for quotes
  def url
    if @ticket.user && !@ticket.target.is_a?(Instance)
      routes.dashboard_user_requests_for_quote_path(ticket)
    end
  end

  # returns 'request' if free booking is enabled for the target listing
  # otherwise returns 'offer'
  def rfq
    if ticket.target.action_free_booking?
      'request'
    else
      'offer'
    end
  end

  # returns the number of messages in this support ticket thread
  def messages_count
    messages.count
  end

  # url to the admin section in the marketplace for this support ticket
  # thread; this is the section where the admin can answer and resolve
  # requests
  def admin_url
    case ticket.target
    when Transactable, Spree::Product
      routes.dashboard_company_support_ticket_path(ticket)
    when Instance
      routes.instance_admin_manage_support_ticket_path(ticket)
    else
      raise NotImplementedError.new("Unknown ticket target: #{ticket.target.class}")
    end
  end

  # numeric identifier for this ticket
  def id
    ticket.id
  end

  def messages
    if ticket.messages.length > 0
      ticket.messages[1..-1]
    else
      []
    end
  end
end

