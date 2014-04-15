class SupportMailer < InstanceMailer
 def request_received(request, message)
   @ticket = request
   @message = message
   mail to: request.first_message.email,
        from: "[#{PlatformContext.current.decorate.name} Support]",
        subject: subject(request, 'Your support request has been received')
 end

 def request_updated(request, message)
   @ticket = request
   @message = message
   mail to: request.first_message.email,
        from: "[#{PlatformContext.current.decorate.name} Support]",
        subject: subject(request, "Your support request was updated")
 end

 def request_replied(request, message)
   @ticket = request
   @message = message
   mail to: request.first_message.email,
        from: "[#{PlatformContext.current.decorate.name} Support]",
        subject: subject(request, "#{message.full_name} replied to your support request")
 end

 def support_received(request, message)
   @ticket = request
   @message = message
   mail to: request.admin_emails,
        from: "[#{PlatformContext.current.decorate.name} Support]",
        subject: subject(request, "#{message.full_name} has submited a support request")
 end

 def support_updated(request, message)
   @ticket = request
   @message = message
   mail to: request.admin_emails,
        from: "[#{PlatformContext.current.decorate.name} Support]",
        subject: subject(request, "#{message.full_name} has updated their support request")
 end

 private

 def subject(request, subject)
   "[Ticket Support #{request.id}] #{request.instance.name} - #{subject}"
 end
end
