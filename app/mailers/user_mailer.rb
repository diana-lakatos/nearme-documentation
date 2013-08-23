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

  def email_verification(instance, user_id)

    @user = User.where('users.verified_at is null AND id = ?', user_id).first
    @instance = instance

    mail to: @user.email, subject: "Email verification" if @user
  end

  if defined? MailView
    class Preview < MailView

      def notify_about_wrong_phone_number
        @user = User.where('mobile_number is not null').first
        ::UserMailer.notify_about_wrong_phone_number(@user)
      end

      def email_verification
        @user = User.where('users.verified_at is null').first
        ::UserMailer.email_verification(Instance.default_instance, @user)
      end

    end
  end

end
