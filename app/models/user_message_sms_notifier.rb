class UserMessageSmsNotifier < SmsNotifier
  def notify_user_about_new_message(platform_context, user_message)
    return unless user_message.recipient.accepts_sms_with_type?(:user_message)
    @user_message = user_message
    @user = user_message.recipient
    @platform_context = platform_context.decorate
    @message_size = 10
    user_message_body = @user_message.body
    @user_message.body = nil
    sms_without_message_body = sms(:to => @user.full_mobile_number)

    @user_message.body = user_message_body
    @message_size = 160 - sms_without_message_body.body.size
    sms :to => @user.full_mobile_number
  end
end

