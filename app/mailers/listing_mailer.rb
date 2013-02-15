class ListingMailer < DesksNearMeMailer

  def share(listing, email, name, sharer, message=nil)
    @listing, @email, @name, @sharer, @message = listing, email, name, sharer, message
    mail :to => "#{name} <#{email}>", :reply_to => "#{sharer.name} <#{sharer.email}>",
      :subject => "#{sharer.name} has shared a listing with you on Desks Near Me"
  end

  if defined? MailView
    class Preview < MailView
      def share
        FactoryGirl.create(:user) unless User.first
        FactoryGirl.create(:listing) unless Listing.first
        ::ListingMailer.share(Listing.first, User.first.email, User.first.name, User.last, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
      end
    end
  end

end
