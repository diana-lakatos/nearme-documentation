class WorkflowStep::ReservationWorkflow::WarnExpiration < WorkflowStep::ReservationWorkflow::BaseStep

  # reservation:
  #   Reservation object
  # enquirer:
  #   enquirer User object
  # lister:
  #   lister User object
  # listing:
  #   Transactable object
  def data
    { reservation: @reservation, enquirer: enquirer, lister: lister, 
      listing: @reservation.transactable, expires_in_hours: expires_in_hours }
  end

  private

  def expires_in_hours
    ((@reservation.ends_at - Time.now)/3600).ceil
  end

end
