class Support::TicketMessageDecorator < Draper::Decorator
  include ApplicationHelper

  delegate_all

  # returns message body with applied text filters
  def message
    if ticket.target_rfq?
      mask_phone_and_email_if_necessary(self[:message])
    else
      super
    end
  end
end
