class ListingMessagingMailer < InstanceMailer
  layout 'mailer' 

  def email_message_from_guest(platform_context, listing_message)
    @listing_message = listing_message
    @user = @listing_message.listing.administrator
    @platform_context = platform_context.decorate

    mail(to: @user.email,
         subject: instance_prefix("You received a message!", @platform_context),
         platform_context: platform_context)
  end

  def email_message_from_host(platform_context, listing_message)
    @listing_message = listing_message
    @user = @listing_message.owner
    @platform_context = platform_context.decorate

    mail(to: @user.email,
         subject: instance_prefix("You received a message!", @platform_context),
         platform_context: platform_context)
  end

end
