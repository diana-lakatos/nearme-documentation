class ListingMailer < InstanceMailer
  layout 'mailer'

  def share(instance_id, listing_id, email, name, sharer_id, message=nil)
    @listing = Listing.find(listing_id)
    @email = email
    @name = name
    @sharer = User.find(sharer_id)
    @message = message
    @instance = Instance.find(instance_id)

    mail(to: "#{name} <#{email}>",
         reply_to: "#{@sharer.name} <#{@sharer.email}>",
         subject: "#{@sharer.name} has shared a listing with you on Desks Near Me",
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
