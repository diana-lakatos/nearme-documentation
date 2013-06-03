module Analytics::ReservationEvents
  def opened_booking_modal(reservation, custom_options = {})
    track_event 'Opened the Booking Modal', reservation, custom_options
  end

  def requested_a_booking(reservation, custom_options = {})
    track_event 'Requested a Booking', reservation, custom_options
  end

  def confirmed_a_booking(reservation, custom_options = {})
    track_event 'Confirmed a Booking', reservation, custom_options
    charge reservation.owner.id, reservation.total_amount_dollars
  end

  def rejected_a_booking(reservation, custom_options = {})
    track_event 'Rejected a Booking', reservation, custom_options
  end

  def cancelled_a_booking(reservation, custom_options = {})
    track_event 'Cancelled a Booking', reservation, custom_options
    charge reservation.owner.id, reservation.total_negative_amount_dollars
  end

  def booking_expired(reservation, custom_options = {})
    track_event 'Booking Expired', reservation, custom_options
  end
end

