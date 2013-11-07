if defined? MailView
  class Previewers::InquiryMailer < MailView

    def inquiring_user_notification
      inquiry_from_db = Inquiry.first
      inquiry = inquiry_from_db || FactoryGirl.create(:inquiry, inquiring_user: User.first, listing: Listing.first)

      mailer = ::InquiryMailer.inquiring_user_notification(PlatformContext.new, inquiry)

      inquiry.destroy unless inquiry_from_db
      mailer
    end

    def listing_creator_notification
      inquiry_from_db = Inquiry.first
      inquiry = inquiry_from_db || FactoryGirl.create(:inquiry, inquiring_user: User.first, listing: Listing.first)

      mailer = ::InquiryMailer.listing_creator_notification(PlatformContext.new, inquiry)

      inquiry.destroy unless inquiry_from_db
      mailer
    end

  end
end
