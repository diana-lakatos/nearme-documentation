if defined? MailView
  class Previewers::ListingMessagingMailer < MailView

    def email_message_from_guest
      ::ListingMessagingMailer.email_message_from_guest(PlatformContext.new, listing_message)
    end

    def email_message_from_host
      ::ListingMessagingMailer.email_message_from_host(PlatformContext.new, listing_message)
    end

    private

    def listing_message
      ListingMessage.last || FactoryGirl.create(:listing_message)
    end

  end
end
