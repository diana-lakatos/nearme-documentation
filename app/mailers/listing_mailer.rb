class ListingMailer < InstanceMailer
  layout 'mailer'

  def share(listing, email, name, sharer, message=nil)
    @listing = listing
    @email = email
    @name = name
    @sharer = sharer
    @message = message
    @instance = listing.instance

    mail(to: "#{name} <#{email}>", :reply_to => "#{sharer.name} <#{sharer.email}>",
         instance: @instance)
  end

  if defined? MailView
    class Preview < MailView
      def share
        FactoryGirl.create(:user) unless User.first
        FactoryGirl.create(:listing) unless Listing.first
        FactoryGirl.create(:instance) unless Instance.first
        ::ListingMailer.share(Listing.first, User.first.email, User.first.name, User.last, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
      end
    end
  end

end
