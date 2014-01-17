class UserMessageMailerPreview < MailView

  def email_message_from_guest
    ::UserMessageMailer.email_message_from_guest(PlatformContext.new, user_message)
  end

  def email_message_from_host
    ::UserMessageMailer.email_message_from_host(PlatformContext.new, user_message)
  end

  private

  def user_message
    UserMessage.last || FactoryGirl.create(:user_message, author: User.last, thread_context: Listing.searchable.last)
  end

end
