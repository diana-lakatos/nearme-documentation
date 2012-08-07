class ListingMailer < DesksNearMeMailer
  def share(listing, email, name, sharer, message=nil)
    @listing, @email, @name, @sharer, @message = listing, email, name, sharer, message
    mail :to => "#{name} <#{email}>", :reply_to => "#{sharer.name} <#{sharer.email}>",
      :subject => "#{sharer.name} has shared a listing with you on Desks Near Me"
  end
end
