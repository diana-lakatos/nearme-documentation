class ReservationPreBookingJob < Job

  def after_initialize(reservation_id)
    @reservation_id = reservation_id
  end

  def perform
    @reservation = Reservation.find_by_id(reservation_id)
    if @reservation
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::OneDayToBooking, @reservation_id) if @reservation.confirmed?
    end
  end

end
