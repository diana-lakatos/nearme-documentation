class Support::ReceiveMails
  def start!
    return if PlatformContext.current.instance.support_imap_hash.blank?
    # Mailman connects to the mailbox and checks for new emails
    Mailman::Application.run(config) do
      # If subject is following one of following patterns, invoke 'receive'
      # method in Support::TicketMessage class - it will just create new ticket message
      # in our system
      subject("[Support Ticket #%ticket_id%]", Support::TicketMessage)
      subject("[Ticket Support #%ticket_id%]", Support::TicketMessage)
      subject("[Ticket Support %ticket_id%]", Support::TicketMessage)

      # If subject does not follow our convention, it means that this is new email
      # and we will create a Support::Ticket for it. We will also notify
      # enquirer and all administrators (via custom alerts - this can be changed per
      # marketplace ) that we received the email
      default do
        Support::Ticket.new.receive(message, params)
      end
    end
  rescue Net::IMAP::NoResponseError
    puts "#{PlatformContext.current.instance.name}(id=#{PlatformContext.current.instance.id}) support_imap_hash not valid"
  end

  def config
    Mailman::Configuration.new.tap do |c|
      c.imap = YAML.load(PlatformContext.current.instance.support_imap_hash).symbolize_keys
      c.poll_interval = 0
    end
  end
end
