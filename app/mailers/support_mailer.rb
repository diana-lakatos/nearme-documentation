class SupportMailer < InstanceMailer
  def request_received(request, message)
    @ticket = request
    @message = message
    mail to: request.first_message.email,
      subject: instance_subject(request, 'Your support request has been received')
  end

  def request_updated(request, message)
    @ticket = request
    @message = message
    mail to: request.first_message.email,
      subject: instance_subject(request, "Your support request was updated")
  end

  def request_replied(request, message)
    @ticket = request
    @message = message
    mail to: request.first_message.email,
      subject: instance_subject(request, "#{message.full_name} replied to your support request")
  end

  def support_received(request, message)
    @ticket = request
    @message = message
    mail to: request.admin_emails,
      subject: instance_subject(request, "#{message.full_name} has submited a support request")
  end

  def support_updated(request, message)
    @ticket = request
    @message = message
    mail to: request.admin_emails,
      subject: instance_subject(request, "#{message.full_name} has updated their support request")
  end

  def rfq_request_received(request, message)
    @ticket = request
    @message = message
    mail to: request.first_message.email,
      subject: rfq_subject(request, 'Your request for quote has been received')
  end

  def rfq_request_updated(request, message)
    @ticket = request
    @message = message
    mail to: request.first_message.email,
      subject: rfq_subject(request, "Your request for quote was updated")
  end

  def rfq_request_replied(request, message)
    @ticket = request
    @message = message
    mail to: request.first_message.email,
      subject: rfq_subject(request, "#{message.full_name} replied to your request for quote")
  end

  def rfq_support_received(request, message)
    @ticket = request
    @message = message
    mail to: request.assigned_to.try(:email),
      subject: rfq_subject(request, "#{message.full_name} has submited a request for quote")
  end

  def rfq_support_updated(request, message)
    @ticket = request
    @message = message
    mail to: request.assigned_to.try(:email),
      subject: rfq_subject(request, "#{message.full_name} has updated their request for quote")
  end

  private

  def instance_subject(request, subject)
    "[Ticket Support #{request.id}] #{request.instance.name} - #{subject}"
  end

  def rfq_subject(request, subject)
    subject
  end
end

