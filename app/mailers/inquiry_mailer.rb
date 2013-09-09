class InquiryMailer < InstanceMailer
  layout 'mailer'

  def inquiring_user_notification(inquiry)
    @inquiry = inquiry
    current_instance = @inquiry.instance

    mailer = find_mailer(instance: current_instance)

    mail(to: inquiry.inquiring_user.full_email,
         subject: mailer.liquid_subject('inquiry' => @inquiry),
         instance: current_instance)
  end

  def listing_creator_notification(inquiry)
    @inquiry = inquiry
    current_instance = @inquiry.instance

    mailer = find_mailer(instance: current_instance)

    mail(to: inquiry.listing.creator.full_email,
         subject: mailer.liquid_subject('inquiry' => @inquiry),
         reply_to: inquiry.inquiring_user.full_email,
         instance: current_instance)
  end

  if defined? MailView
    class Preview < MailView

      def inquiring_user_notification
        ::InquiryMailer.inquiring_user_notification(Inquiry.first)
      end

      def listing_creator_notification
        ::InquiryMailer.listing_creator_notification(Inquiry.first)
      end
    end
  end
end
