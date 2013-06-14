class ReservationSmsNotifier < SmsNotifier
  def notify_host_with_confirmation(reservation)
    @reservation = reservation
    sms :to => reservation.listing.creator.mobile_number
  end
end

