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

  if defined? MailView
    class Preview < MailView

      def notify_about_wrong_phone_number
        @user = User.where('mobile_number is not null').first
        ::UserMailer.notify_about_wrong_phone_number(@user)
      end

    end
  end

end
