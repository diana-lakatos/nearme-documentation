class InquiryMailer < InstanceMailer
  layout 'mailer'

  def inquiring_user_notification(instance_id, inquiry_id)
    @inquiry = Inquiry.find(inquiry_id)
    current_instance = Instance.find(instance_id)

    mail(to: @inquiry.inquiring_user.full_email,
         subject: "We've passed on your inquiry about #{@inquiry.listing.name}",
         instance: current_instance)
  end

  def listing_creator_notification(instance_id, inquiry_id)
    @inquiry = Inquiry.find(inquiry_id)
    current_instance = Instance.find(instance_id)

    mail(to: @inquiry.listing.creator.full_email,
         subject: "New enquiry from #{@inquiry.inquiring_user.name} about #{@inquiry.listing.name}",
         reply_to: @inquiry.inquiring_user.full_email,
         instance: current_instance)
  end

  if defined? MailView
    class Preview < MailView

      def inquiring_user_notification
        ::InquiryMailer.inquiring_user_notification(Instance.first.id, Inquiry.first.id)
      end

      def listing_creator_notification
        ::InquiryMailer.listing_creator_notification(Instance.first.id, Inquiry.first.id)
      end
    end
  end
end
