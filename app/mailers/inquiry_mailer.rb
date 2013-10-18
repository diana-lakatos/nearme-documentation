class InquiryMailer < InstanceMailer
  layout 'mailer'

  def inquiring_user_notification(theme, inquiry)
    @theme = theme
    @inquiry = inquiry

    mail(to: @inquiry.inquiring_user.full_email,
         subject: "We've passed on your inquiry about #{@inquiry.listing.name}",
         theme: theme)
  end

  def listing_creator_notification(theme, inquiry)
    @theme = theme
    @inquiry = inquiry

    mail(to: @inquiry.listing.creator.full_email,
         subject: "New enquiry from #{@inquiry.inquiring_user.name} about #{@inquiry.listing.name}",
         reply_to: @inquiry.inquiring_user.full_email,
         theme: theme)
  end

  if defined? MailView
    class Preview < MailView

      def inquiring_user_notification
        inquiry_from_db = Inquiry.first
        inquiry = inquiry_from_db || FactoryGirl.create(:inquiry, inquiring_user: User.first, listing: Listing.first)

        mailer = ::InquiryMailer.inquiring_user_notification(Theme.first, inquiry)

        inquiry.destroy unless inquiry_from_db
        mailer
      end

      def listing_creator_notification
        inquiry_from_db = Inquiry.first
        inquiry = inquiry_from_db || FactoryGirl.create(:inquiry, inquiring_user: User.first, listing: Listing.first)

        mailer = ::InquiryMailer.listing_creator_notification(Theme.first, inquiry)

        inquiry.destroy unless inquiry_from_db
        mailer
      end
    end
  end
end
