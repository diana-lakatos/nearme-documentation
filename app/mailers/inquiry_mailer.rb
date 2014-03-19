class InquiryMailer < InstanceMailer
  layout 'mailer'

  def inquiring_user_notification(inquiry)
    @inquiry = inquiry

    mail to: @inquiry.inquiring_user.full_email,
         subject_locals: { inquiry: @inquiry }
  end

  def listing_creator_notification(inquiry)
    @inquiry = inquiry

    mail(to: @inquiry.listing.administrator.full_email,
         subject_locals: { inquiry: @inquiry },
         reply_to: @inquiry.inquiring_user.full_email)
  end
end
