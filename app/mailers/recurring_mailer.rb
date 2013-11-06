class RecurringMailer < InstanceMailer
  layout 'mailer' 

  def analytics(company, user)
    @company = company
    @user = user
    @listing = @company.listings.first
    @platform_context = PlatformContext.new

    mail to: @user.email, 
          subject: "#{@user.first_name}, we have potential guests for you!",
          platform_context: @platform_context
  end

  def request_photos(listing)
    @listing = listing
    @user = @listing.administrator
    @platform_context = PlatformContext.new
    @bcc = (@user == @listing.creator) ? [] : @listing.creator

    mail to: @user.email, 
           bcc: @bcc,
           subject: "Give the final touch to your listing with some photos!",
           platform_context: @platform_context
  end

  def share(listing)
    @listing = listing
    @user = @listing.administrator
    @platform_context = PlatformContext.new
    @bcc = (@user == @listing.creator) ? [] : @listing.creator

    mail to: @user.email, 
           bcc: @bcc,
           subject: "Share your listing '#{@listing.name}' at #{@listing.location.street } and increase bookings!",
           platform_context: @platform_context
  end


  if defined? MailView
    class Preview < MailView

      def analytics
        ::RecurringMailer.analytics(Company.first, User.all.select{|u| !u.companies.count.zero?}.first)
      end

      def request_photos
        ::RecurringMailer.request_photos(Listing.first)
      end

      def share
        ::RecurringMailer.share(Reservation.first.listing)
      end
    end
  end

end
