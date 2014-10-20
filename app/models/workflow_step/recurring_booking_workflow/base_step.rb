class WorkflowStep::RecurringBookingWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize(recurring_booking_id)
    @recurring_booking = RecurringBooking.find_by_id(recurring_booking_id)
  end

  def workflow_type
    'recurring_booking'
  end

  def lister
    @recurring_booking.host
  end

  def enquirer
    @recurring_booking.owner
  end

  def data
    { recurring_booking: @recurring_booking, reservation: @recurring_booking.reservations.first, user: lister, host: enquirer, listing: @recurring_booking.listing }
  end

end
