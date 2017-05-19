# frozen_string_literal: true
class Support::TicketDrop < BaseDrop
  def initialize(ticket)
    @source = ticket.decorate
  end

  # @!method id
  #   @return [Integer] numeric identifier for this ticket
  # @!method first_message
  #   @return [Support::TicketMessageDrop] first message for this support ticket thread
  # @!method target_rfq?
  #   @return [Boolean] whether the ticket is connected to a Transactable
  # @!method show_target_path
  #   @return [String] url to the Transactable to which a ticket is connected
  # @!method target
  #   @return [Object] object to which this ticket is connected
  # @!method verb
  #   @return [String] status of the ticket in past tense
  # @!method open_text
  #   @return [String] text to be displayed for the action of opening a ticket e.g.
  #     'View and resolve' for opened tickets, or 'View' for closed tickets
  # @!method updated_at
  #   @return [Date] updated at date for the ticket
  # @!method recent_message
  #   @return [Support::TicketMessageDrop] most recent message in the thread
  delegate :id, :first_message, :target_rfq?, :show_target_path, :target, :verb, :open_text,
           :updated_at, :recent_message, to: :source

  # @return [String] date/time when this ticket was created
  # @todo -- remove, DIY
  def created_at
    source.created_at.to_s
  end

  # @return [String] url to this user's requests for quotes
  # @todo -- depracate, url filter
  def url
    routes.dashboard_user_requests_for_quote_path(source) if @source.user && !@source.target.is_a?(Instance)
  end

  # @return [String] 'request' if free booking is enabled for the target listing
  #   otherwise returns 'offer'
  def rfq
    if source.target.action_free_booking?
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
    case source.target
    when Transactable
      routes.dashboard_company_support_ticket_path(source)
    when Instance
      routes.instance_admin_support_ticket_path(source)
    else
      raise NotImplementedError, "Unknown ticket target: #{source.target.class}"
    end
  end

  # @return [Array<Support::TicketMessageDrop>] the messages in this thread with the first one
  #   omitted
  def messages
    if !source.messages.empty?
      source.messages[1..-1]
    else
      []
    end
  end
end
