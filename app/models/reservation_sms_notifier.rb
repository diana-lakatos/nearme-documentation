class ReservationSmsNotifier < SmsNotifier
  def notify_host_with_confirmation(reservation)
    return unless reservation.listing.creator.accepts_sms?
    @reservation = reservation
    sms :to => reservation.listing.creator.full_mobile_number
  end
end

