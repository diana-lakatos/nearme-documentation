class RatingMailer < InstanceMailer
  layout 'mailer'

  def request_guest_rating(reservation)
    @who_is_rating      = 'host'
    user = reservation.administrator

    @who_is_rated       = 'guest'
    @subject = reservation.owner

    @subject = "How was your experience hosting #{reservation.owner.first_name}?"
    request_rating(reservation, user)
  end

  def request_host_rating(reservation)
    @who_is_rating    = 'guest'
    user  = reservation.owner

    @who_is_rated     = 'host'
    @subject = reservation.administrator

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
         subject_locals: { reservation: @reservation, listing: @listing },
         template_name: "request_rating_of_#{@who_is_rated}_from_#{@who_is_rating}"
  end

end
