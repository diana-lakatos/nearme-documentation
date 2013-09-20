class UserMailer < InstanceMailer
  helper SharingHelper

  layout false

  def notify_about_wrong_phone_number(user, instance)
    @user = user
    mail(to: @user.email,
         subject:  instance_prefix("We couldn't send you text message", instance),
         instance: instance)
  end

  def email_verification(user, instance)
    @user = user
    @instance = instance

    unless @user.verified_at
      mail to: @user.email, 
           subject: "Email verification",
           instance: instance
    end
  end

  if defined? MailView
    class Preview < MailView

      def notify_about_wrong_phone_number
        ::UserMailer.notify_about_wrong_phone_number(User.where('mobile_number is not null').first, Instance.default_instance)
      end

      def email_verification
        ::UserMailer.email_verification(User.where('users.verified_at is null').first, Instance.default_instance)
      end

    end
  end

end
