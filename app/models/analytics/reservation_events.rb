module Analytics::ReservationEvents

  def opened_booking_modal(reservation, custom_options = {})
    track 'Opened the Booking Modal', reservation, custom_options
  end

  def requested_a_booking(reservation, custom_options = {})
    track 'Requested a Booking', reservation, custom_options
  end

  def confirmed_a_booking(reservation, custom_options = {})
    track 'Confirmed a Booking', reservation, custom_options
    # commented out because I dont' think this is semantically correct?
    #  - charges should reflect internal revenue yielded by us, i.e. to
    #    report on average user revenue etc.
    #  - so, we should be triggering charges when we do something that yields
    #    us revenue, and store our 10% cut or whatever it is for when a user
    #    incurs an actual charge that goes to us.
    #track_charge reservation.owner.id, reservation.total_amount_dollars
  end

  def rejected_a_booking(reservation, custom_options = {})
    track 'Rejected a Booking', reservation, custom_options
  end

  def cancelled_a_booking(reservation, custom_options = {})
    track 'Cancelled a Booking', reservation, custom_options
    # commented out because I dont' think this is semantically correct?
    #track_charge reservation.owner.id, reservation.total_negative_amount_dollars
  end

  def booking_expired(reservation, custom_options = {})
    track 'Booking Expired', reservation, custom_options
  end

end

