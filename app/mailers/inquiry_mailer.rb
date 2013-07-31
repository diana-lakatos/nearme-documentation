class InquiryMailer < DesksNearMeMailer

  def inquiring_user_notification(instance, inquiry)
    @inquiry = inquiry
    @instance = instance

    mail to:      inquiry.inquiring_user.full_email,
         subject: "We've passed on your inquiry about #{inquiry.listing.name}"
  end

  def listing_creator_notification(instance, inquiry)
    @inquiry = inquiry
    @instance = instance

    mail to:       inquiry.listing.creator.full_email,
         subject:  "New enquiry from #{inquiry.inquiring_user.name} about #{inquiry.listing.name}",
         reply_to: inquiry.inquiring_user.full_email
  end

  if defined? MailView
    class Preview < MailView

      def inquiring_user_notification
        ::InquiryMailer.inquiring_user_notification(@instance, Inquiry.first)
      end

      def listing_creator_notification
        ::InquiryMailer.listing_creator_notification(@instance, Inquiry.first)
      end

    end
  end

end
