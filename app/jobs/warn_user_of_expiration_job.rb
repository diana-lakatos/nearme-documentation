class WarnUserOfExpirationJob < Job
  def after_initialize(reservation_id)
    @reservation_id = reservation_id
  end

  def perform
    @reservation = Reservation.find(@reservation_id)
    if @reservation.confirmed? && @reservation.ends_at.present? && @reservation.ends_at > Time.now + 10.minutes
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::WarnExpiration, @reservation.id)
    end
  end
end
