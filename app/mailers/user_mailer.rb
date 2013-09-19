class UserMailer < InstanceMailer
  helper SharingHelper

  layout false

  def notify_about_wrong_phone_number(user)
    @user = user
    mail(to: @user.email,
         subject: instance_prefix("We couldn't send you text message", @user.instance),
         instance: @user.instance)
  end

  def email_verification(user)
    user = user
    return unless user.verified_at.nil?
    @user = user
    mail(to: @user.email,
         subject: 'Email verification',
         instance: @user.instance)
  end

  if defined? MailView
    class Preview < MailView

      def notify_about_wrong_phone_number
        ::UserMailer.notify_about_wrong_phone_number(User.where('mobile_number is not null').first)
      end

      def email_verification
        ::UserMailer.email_verification(User.where('users.verified_at is null').first)
      end

    end
  end

end
