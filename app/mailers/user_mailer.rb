class UserMailer < InstanceMailer
  helper SharingHelper

  layout 'mailer' 

  def notify_about_wrong_phone_number(request_context, user)
    @user = user
    mail(to: @user.email,
         subject:  instance_prefix("We couldn't send you text message", request_context),
         request_context: request_context)
  end

  def email_verification(request_context, user)
    @user = user
    @request_context = request_context

    unless @user.verified_at
      mail to: @user.email, 
           subject: "Email verification",
           request_context: request_context
    end
  end

  if defined? MailView
    class Preview < MailView

      def notify_about_wrong_phone_number
        ::UserMailer.notify_about_wrong_phone_number(Controller::RequestContext.new, User.where('mobile_number is not null').first)
      end

      def email_verification
        ::UserMailer.email_verification(Controller::RequestContext.new, User.where('users.verified_at is null').first)
      end

    end
  end

end
