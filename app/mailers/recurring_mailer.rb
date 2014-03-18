class RecurringMailer < InstanceMailer
  layout 'mailer'

  def analytics(company, user)
    @company = company
    @user = user
    @listing = @company.listings.first

    mail to: @user.email,
         subject_locals: { user: @user }
  end

  def request_photos(listing)
    @listing = listing
    @user = @listing.administrator

    mail to: @user.email
  end

  def share(listing)
    @listing = listing
    @user = @listing.administrator

    mail to: @user.email,
         subject_locals: { user: @user, listing: @listing }
  end

  def mail_type
    DNM::MAIL_TYPES::NON_TRANSACTIONAL
  end

end
