class InquiryMailer < InstanceMailer
  layout 'mailer'

  def inquiring_user_notification(platform_context, inquiry)
    @platform_context = platform_context
    @inquiry = inquiry

    mail(to: @inquiry.inquiring_user.full_email,
         subject: "We've passed on your inquiry about #{@inquiry.listing.name}",
         platform_context: platform_context)
  end

  def listing_creator_notification(platform_context, inquiry)
    @platform_context = platform_context
    @inquiry = inquiry

    mail(to: @inquiry.listing.creator.full_email,
         subject: "New enquiry from #{@inquiry.inquiring_user.name} about #{@inquiry.listing.name}",
         reply_to: @inquiry.inquiring_user.full_email,
         platform_context: platform_context)
  end

  if defined? MailView
    class Preview < MailView

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
end
