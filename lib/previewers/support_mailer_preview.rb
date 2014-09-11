class SupportMailerPreview < MailView
  def request_received
    ::SupportMailer.request_received(ticket, ticket.first_message)
  end

  def request_updated
    ::SupportMailer.request_updated(ticket, ticket.first_message)
  end

  def request_replied
    ::SupportMailer.request_replied(ticket, ticket.first_message)
  end

  def support_received
    ::SupportMailer.support_received(ticket, ticket.first_message)
  end

  def support_updated
    ::SupportMailer.support_updated(ticket, ticket.first_message)
  end

  def rfq_request_received
    ::SupportMailer.rfq_request_received(transactable_ticket, transactable_ticket.first_message)
  end

  def rfq_request_updated
    ::SupportMailer.rfq_request_updated(transactable_ticket, transactable_ticket.first_message)
  end

  def rfq_request_replied
    ::SupportMailer.rfq_request_replied(transactable_ticket, transactable_ticket.first_message)
  end

  def rfq_support_received
    ::SupportMailer.rfq_support_received(transactable_ticket, transactable_ticket.first_message)
  end

  def rfq_support_updated
    ::SupportMailer.rfq_support_updated(transactable_ticket, transactable_ticket.first_message)
  end

  private

  def ticket
    @ticket ||= Support::Ticket.where(target_type: 'Instance').last || FactoryGirl.create(:support_ticket)
  end

  def transactable_ticket
    @transactable_ticket ||= Support::Ticket.where(target_type: 'Transactable').last
  end

end
