class InquiryMailer < InstanceMailer

  def inquiring_user_notification(inquiry)
    @inquiry = inquiry
    current_instance = @inquiry.instance
    self.class.layout 'mailer', instance: current_instance

    mailer = current_instance.find_mailer_for(self)

    mail to:      inquiry.inquiring_user.full_email,
         from:     mailer.from,
         subject: mailer.liquid_subject('inquiry' => @inquiry) do |format|
           format.html { render view_context.action_name, instance: current_instance }
           format.text { render view_context.action_name, instance: current_instance }
         end
  end

  def listing_creator_notification(inquiry)
    @inquiry = inquiry
    current_instance = @inquiry.instance
    self.class.layout 'mailer', instance: current_instance

    mailer = current_instance.find_mailer_for(self)

    mail to:       inquiry.listing.creator.full_email,
         from:     mailer.from,
         subject: mailer.liquid_subject('inquiry' => @inquiry),
         reply_to: inquiry.inquiring_user.full_email do |format|
           format.html { render view_context.action_name, instance: current_instance }
           format.text { render view_context.action_name, instance: current_instance }
         end
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
