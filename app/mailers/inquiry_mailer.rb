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
        ::InquiryMailer.inquiring_user_notification(Theme.first, Inquiry.first)
      end

      def listing_creator_notification
        ::InquiryMailer.listing_creator_notification(Theme.first, Inquiry.first)
      end
    end
  end
end
