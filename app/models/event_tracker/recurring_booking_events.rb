module EventTracker::RecurringBookingEvents
  def reviewed_a_recurring_booking(recurring_booking, custom_options = {})
    track 'Reviewed a Recurring Booking', recurring_booking, custom_options
  end

  def requested_a_recurring_booking(recurring_booking, custom_options = {})
    track 'Requested a Recurring Booking', recurring_booking, custom_options
  end

  def confirmed_a_recurring_booking(recurring_booking, custom_options = {})
    track 'Confirmed a Recurring Booking', recurring_booking, custom_options
  end

  def rejected_a_recurring_booking(recurring_booking, custom_options = {})
    track 'Rejected a Recurring Booking', recurring_booking, custom_options
  end

  def cancelled_a_recurring_booking(recurring_booking, custom_options = {})
    track 'Cancelled a Recurring Booking', recurring_booking, custom_options
  end

  def recurring_booking_expired(recurring_booking, custom_options = {})
    track 'Recurring Booking Expired', recurring_booking, custom_options
  end
end
