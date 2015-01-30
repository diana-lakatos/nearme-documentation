class RatingMailer < InstanceMailer
  layout 'mailer'

  def request_rating_of_guest_from_host(reservation)
    user = reservation.administrator
    @subject = "How was your experience hosting #{reservation.owner.first_name}?"
    request_rating(reservation, user)
  end

  def request_rating_of_host_from_guest(reservation)
    user  = reservation.owner
    @subject = "How was your experience at '#{reservation.listing.name}'?"
    request_rating(reservation, user)
  end

  def mail_type
    DNM::MAIL_TYPES::TRANSACTIONAL
  end

  private

  def request_rating(reservation, user)
    @reservation = reservation
    @listing = @reservation.listing
    @location = @listing.location
    @user = user
    mail to: @user.email,
         subject_locals: { reservation: @reservation, listing: @listing }
  end

end
