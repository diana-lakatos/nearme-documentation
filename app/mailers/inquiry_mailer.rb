class InquiryMailer < InstanceMailer
  layout 'mailer'

  def inquiring_user_notification(platform_context, inquiry)
    @platform_context_decorator = platform_context.decorate
    @inquiry = inquiry

    mail(to: @inquiry.inquiring_user.full_email,
         subject: "We've passed on your inquiry about #{@inquiry.listing.name}",
         platform_context: platform_context)
  end

  def listing_creator_notification(platform_context, inquiry)
    @platform_context_decorator = platform_context.decorate
    @inquiry = inquiry

    mail(to: @inquiry.listing.administrator.full_email,
         subject: "New enquiry from #{@inquiry.inquiring_user.name} about #{@inquiry.listing.name}",
         reply_to: @inquiry.inquiring_user.full_email,
         platform_context: platform_context)
  end
end
