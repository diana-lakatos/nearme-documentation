class ListingMailerPreview < MailView

  def share
    FactoryGirl.create(:user) unless User.first
    FactoryGirl.create(:listing) unless Listing.first
    ::ListingMailer.share(PlatformContext.new, Listing.first, User.first.email, User.first.name, User.last, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
  end

end
