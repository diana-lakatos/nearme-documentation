class UserMailer < DesksNearMeMailer

  helper SharingHelper

  layout false


  def notify_about_wrong_phone_number(user)
    @user = user

    mail to: @user.email,
      from: "support@desksnear.me",
      reply_to: "support@desksnear.me",
      subject: "[Desks Near Me] We couldn't send you text message"
  end

  def email_verification(user)
    @user = user
    unless @user.verified_at
      mail to: @user.email, 
        subject: "Email verification"
    end
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
