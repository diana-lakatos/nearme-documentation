class WorkflowStep::ReservationWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize(reservation_id)
    @reservation = Reservation.find_by_id(reservation_id)
  end

  def workflow_type
    'reservation'
  end

  def lister
    @reservation.host
  end

  def enquirer
    @reservation.owner
  end

  def data
    { reservation: @reservation, user: lister, host: enquirer, listing: @reservation.listing }
  end

  def transactable_type_id
    @reservation.try(:listing).try(:transactable_type_id)
  end

end
