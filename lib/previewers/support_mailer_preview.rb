class SupportMailerPreview < MailView
  def request_received
    model = Support::Ticket.last || FactoryGirl.create(:support_ticket)
    ::SupportMailer.request_received(model, model.first_message)
  end

  def request_updated
    model = Support::Ticket.last || FactoryGirl.create(:support_ticket)
    ::SupportMailer.request_updated(model, model.first_message)
  end

  def request_replied
    model = Support::Ticket.last || FactoryGirl.create(:support_ticket)
    ::SupportMailer.request_replied(model, model.first_message)
  end

  def support_received
    model = Support::Ticket.last || FactoryGirl.create(:support_ticket)
    ::SupportMailer.support_received(model, model.first_message)
  end

  def support_updated
    model = Support::Ticket.last || FactoryGirl.create(:support_ticket)
    ::SupportMailer.support_updated(model, model.first_message)
  end
end
