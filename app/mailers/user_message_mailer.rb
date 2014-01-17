class UserMessageMailer < InstanceMailer
  layout 'mailer' 

  def email_message_from_guest(platform_context, user_message)
    @user_message = user_message
    @user = @user_message.recipient
    @platform_context = platform_context.decorate

    mail(to: @user.email,
         subject: instance_prefix("You received a message!", @platform_context),
         platform_context: platform_context)
  end

  def email_message_from_host(platform_context, user_message)
    @user_message = user_message
    @user = @user_message.recipient
    @platform_context = platform_context.decorate

    mail(to: @user.email,
         subject: instance_prefix("You received a message!", @platform_context),
         platform_context: platform_context)
  end
end
