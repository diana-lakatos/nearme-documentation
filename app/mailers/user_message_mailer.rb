class UserMessageMailer < InstanceMailer
  layout 'mailer'

  def email_message_from_guest(user_message)
    @user_message = user_message.decorate
    @user = @user_message.recipient

    mail(to: @user.email,
         subject: instance_prefix("You received a message!"))
  end

  def email_message_from_host(user_message)
    @user_message = user_message.decorate
    @user = @user_message.recipient

    mail(to: @user.email,
         subject: instance_prefix("You received a message!"))
  end
end
