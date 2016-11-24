# frozen_string_literal: true
class Support::TicketDrop < BaseDrop
  # @return [Support::TicketDrop]
  attr_reader :ticket

  def initialize(ticket)
    @ticket = ticket
  end

  # @!method first_message
  #   @return [Support::TicketMessageDrop] first message for this support ticket thread
  delegate :first_message, to: :ticket

  # @return [String] date/time when this ticket was created
  # @todo -- remove, DIY
  def created_at
    ticket.created_at.to_s
  end

  # @return [String] url to this user's requests for quotes
  # @todo -- depracate, url filter
  def url
    routes.dashboard_user_requests_for_quote_path(ticket) if @ticket.user && !@ticket.target.is_a?(Instance)
  end

  # @return [String] 'request' if free booking is enabled for the target listing
  #   otherwise returns 'offer'
  def rfq
    if ticket.target.action_free_booking?
      'request'
    else
      'offer'
    end
  end

  # @!method messages_count
  #   @return [Integer] the number of messages in this support ticket thread
  delegate :count, to: :messages, prefix: true

  # @return [String] url to the admin section in the marketplace for this support ticket
  #   thread; this is the section where the admin can answer and resolve requests
  # @todo -- depracate, url filter
  def admin_url
    case ticket.target
    when Transactable
      routes.dashboard_company_support_ticket_path(ticket)
    when Instance
      routes.instance_admin_support_ticket_path(ticket)
    else
      raise NotImplementedError, "Unknown ticket target: #{ticket.target.class}"
    end
  end

  # @!method id
  #   @return [Integer] numeric identifier for this ticket
  delegate :id, to: :ticket

  # @return [Array<Support::TicketMessageDrop>] the messages in this thread with the first one
  #   omitted
  def messages
    if !ticket.messages.empty?
      ticket.messages[1..-1]
    else
      []
    end
  end
end
