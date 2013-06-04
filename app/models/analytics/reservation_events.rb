module Analytics::ReservationEvents

  def opened_booking_modal(reservation, custom_options = {})
    track 'Opened the Booking Modal', reservation, custom_options
  end

  def requested_a_booking(reservation, custom_options = {})
    track 'Requested a Booking', reservation, custom_options
  end

  def confirmed_a_booking(reservation, custom_options = {})
    track 'Confirmed a Booking', reservation, custom_options
    track_charge reservation.owner.id, reservation.total_amount_dollars
  end

  def rejected_a_booking(reservation, custom_options = {})
    track 'Rejected a Booking', reservation, custom_options
  end

  def cancelled_a_booking(reservation, custom_options = {})
    track 'Cancelled a Booking', reservation, custom_options
    track_charge reservation.owner.id, reservation.total_negative_amount_dollars
  end

  def booking_expired(reservation, custom_options = {})
    track 'Booking Expired', reservation, custom_options
  end

end

