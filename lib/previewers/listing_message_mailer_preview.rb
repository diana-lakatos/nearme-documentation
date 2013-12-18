class ListingMessageMailerPreview < MailView

  def email_message_from_guest
    ::ListingMessageMailer.email_message_from_guest(PlatformContext.new, listing_message)
  end

  def email_message_from_host
    ::ListingMessageMailer.email_message_from_host(PlatformContext.new, listing_message)
  end

  private

  def listing_message
    ListingMessage.last || FactoryGirl.create(:listing_message)
  end

end
