class UserMailer < InstanceMailer
  helper SharingHelper

  layout 'mailer' 

  def notify_about_wrong_phone_number(platform_context, user)
    @user = user
    mail(to: @user.email,
         subject:  instance_prefix("We couldn't send you text message", platform_context),
         platform_context: platform_context)
  end

  def email_verification(platform_context, user)
    @user = user
    @platform_context = platform_context
    @platform_context_decorator = platform_context.decorate

    unless @user.verified_at
      mail to: @user.email, 
           subject: "Email verification",
           platform_context: platform_context
    end
  end

  if defined? MailView
    class Preview < MailView

      def notify_about_wrong_phone_number
        ::UserMailer.notify_about_wrong_phone_number(PlatformContext.new, User.where('mobile_number is not null').first)
      end

      def email_verification
        ::UserMailer.email_verification(PlatformContext.new, User.where('users.verified_at is null').first)
      end

    end
  end

end
