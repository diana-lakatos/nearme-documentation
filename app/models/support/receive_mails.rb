class Support::ReceiveMails
  def start!
    return if PlatformContext.current.instance.support_imap_hash.blank?
    Mailman::Application.run(config) do
      subject("[Support Ticket #%ticket_id%]", Support::TicketMessage)
      subject("[Ticket Support #%ticket_id%]", Support::TicketMessage)
      default do
        Support::Ticket.new.receive(message, params)
      end
    end
  end

  def config
    Mailman::Configuration.new.tap do |c|
      c.imap = YAML.load(PlatformContext.current.instance.support_imap_hash).symbolize_keys
      c.poll_interval = 0
    end
  end
end
