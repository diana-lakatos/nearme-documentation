class Support::ReceiveMails
  def start!
    Mailman::Application.run(config) do
      subject("[Support Ticket #%ticket_id%]", Support::TicketMessage)
      default do
        Support::Ticket.new.receive(message, params)
      end
    end
  end

  def config
    Mailman::Configuration.new.tap do |c|
      c.imap = YAML.parse(PlatformContext.current.instance.support_imap_hash)
      c.poll_interval = 0
    end
  end
end
