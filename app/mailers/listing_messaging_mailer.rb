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


  if defined? MailView
    class Preview < MailView

      def email_message_from_guest
        ::ListingMessagingMailer.email_message_from_guest(PlatformContext.new, listing_message)
      end

      def email_message_from_host
        ::ListingMessagingMailer.email_message_from_host(PlatformContext.new, listing_message)
      end

      private

      def listing_message
        ListingMessage.last || FactoryGirl.create(:listing_message)
      end
    end
  end

end
