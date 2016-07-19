class ReservationPreBookingJob < Job
  def after_initialize(reservation_id)
    @reservation_id = reservation_id
  end

  def perform
    @reservation = Order.find_by_id(@reservation_id)
    if @reservation && @reservation.confirmed?
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::OneDayToBooking, @reservation_id)
    end
  end
end
