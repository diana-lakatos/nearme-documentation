class RecurringMailer < InstanceMailer
  layout 'mailer'

  def analytics(company, user)
    @company = company
    @user = user
    @listing = @company.listings.first

    mail to: @user.email,
          subject: "#{@user.first_name}, we have potential guests for you!"
  end

  def request_photos(listing)
    @listing = listing
    @user = @listing.administrator

    mail to: @user.email,
           subject: "Give the final touch to your listing with some photos!"
  end

  def share(listing)
    @listing = listing
    @user = @listing.administrator

    mail to: @user.email,
           subject: "Share your listing '#{@listing.name}' at #{@listing.location.street } and increase bookings!"
  end

  def mail_type
    DNM::MAIL_TYPES::NON_TRANSACTIONAL
  end

end
