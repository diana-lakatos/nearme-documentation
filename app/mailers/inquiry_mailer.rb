class InquiryMailer < InstanceMailer
  layout 'mailer'

  def inquiring_user_notification(inquiry)
    @inquiry = inquiry

    if @inquiry.inquiring_user.present?
      mail to: @inquiry.inquiring_user.full_email,
        subject_locals: { inquiry: @inquiry }
    else
      Rails.logger.warn "Inquiry #{inquiry.id} inquiring_user_notification not sent due to lack of administrator or inquiring user"
    end
  end

  def listing_creator_notification(inquiry)
    @inquiry = inquiry

    if @inquiry.listing.administrator.present? && @inquiry.inquiring_user.present?
      mail(to: @inquiry.listing.administrator.full_email,
           subject_locals: { inquiry: @inquiry },
           reply_to: @inquiry.inquiring_user.full_email)
    else
      Rails.logger.warn "Inquiry #{inquiry.id} listing_creator_notification not sent due to lack of administrator or inquiring user"
    end
  end
end
