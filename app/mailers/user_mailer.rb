class UserMailer < DesksNearMeMailer

  helper SharingHelper

  layout false

  def notify_about_wrong_phone_number(user)
    @user = user

    mailer = @user.instance.find_mailer_for(self)

    mail to:    @user.email,
      bcc:      mailer.bcc,
      from:     mailer.from,
      reply_to: mailer.reply_to,
      subject:  mailer.subject do |format|
        format.html { render view_context.action_name, instance: @user.instance }
        format.text { render view_context.action_name, instance: @user.instance }
      end
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
