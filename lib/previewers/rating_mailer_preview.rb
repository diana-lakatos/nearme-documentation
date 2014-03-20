class RatingMailerPreview < MailView

  def request_guest_rating
    ::RatingMailer.request_rating_of_guest_from_host(Reservation.last)
  end

  def request_host_rating
    ::RatingMailer.request_rating_of_host_from_guest(Reservation.last)
  end

end
