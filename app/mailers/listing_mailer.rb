class ListingMailer < InstanceMailer
  layout 'mailer'

  def share(listing, email, name, sharer, message=nil)
    @listing = listing
    @email = email
    @name = name
    @sharer = sharer
    @message = message

    mail(to: "#{name} <#{email}>",
         reply_to: "#{@sharer.name} <#{@sharer.email}>",
         subject: "#{@sharer.name} has shared a listing with you on #{instance_name}")
  end
end
