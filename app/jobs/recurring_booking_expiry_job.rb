class RecurringBookingExpiryJob < Job
  def after_initialize(recurring_booking_id)
    @recurring_booking = RecurringBooking.find_by_id(recurring_booking_id)
  end

  def perform
    @recurring_booking.try(:perform_expiry!)
  end
end
