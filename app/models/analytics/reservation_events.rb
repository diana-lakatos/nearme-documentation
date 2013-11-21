module Analytics::ReservationEvents

  def reviewed_a_booking(reservation, custom_options = {})
    track 'Reviewed a booking', reservation, custom_options
  end

  def requested_a_booking(reservation, custom_options = {})
    track 'Requested a Booking', reservation, custom_options
  end

  def confirmed_a_booking(reservation, custom_options = {})
    track 'Confirmed a Booking', reservation, custom_options
  end

  def rejected_a_booking(reservation, custom_options = {})
    track 'Rejected a Booking', reservation, custom_options
  end

  def cancelled_a_booking(reservation, custom_options = {})
    track 'Cancelled a Booking', reservation, custom_options
  end

  def booking_expired(reservation, custom_options = {})
    track 'Booking Expired', reservation, custom_options
  end

end

