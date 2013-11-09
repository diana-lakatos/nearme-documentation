class RatingMailerPreview < MailView

  def request_guest_rating
    ::RatingMailer.request_guest_rating(Reservation.last)
  end

  def request_host_rating
    ::RatingMailer.request_host_rating(Reservation.last)
  end

end
