class ListingMailerPreview < MailView

  def share
    FactoryGirl.create(:user) unless User.first
    FactoryGirl.create(:listing) unless Transactablefirst
    ::ListingMailer.share(Transactablefirst, User.first.email, User.first.name, User.last, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
  end

end
