class ListingMailer < InstanceMailer
  layout 'mailer'

  def share(platform_context, listing, email, name, sharer, message=nil)
    @listing = listing
    @email = email
    @name = name
    @sharer = sharer
    @message = message
    @platform_context_decorator = platform_context.decorate

    mail(to: "#{name} <#{email}>",
         reply_to: "#{@sharer.name} <#{@sharer.email}>",
         subject: "#{@sharer.name} has shared a listing with you on Desks Near Me",
         platform_context: platform_context)
  end

  if defined? MailView
    class Preview < MailView
      def share
        FactoryGirl.create(:user) unless User.first
        FactoryGirl.create(:listing) unless Listing.first
        ::ListingMailer.share(PlatformContext.new, Listing.first, User.first.email, User.first.name, User.last, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
      end
    end
  end

end
