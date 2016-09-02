class WorkflowStep::ReservationWorkflow::BaseStep < WorkflowStep::BaseStep

  def self.belongs_to_transactable_type?
    true
  end

  def initialize(reservation_id)
    @reservation = Order.find_by_id(reservation_id)
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

  def transactable
    @reservation.transactable
  end

  def collaborators
    transactable.try(:collaborators_email_recipients)
  end

  # reservation:
  #   Reservation object
  # user:
  #   listing User object
  # host:
  #   enquiring User object
  # listing:
  #   Transactable object
  def data
    { reservation: @reservation, user: enquirer, host: lister, listing: @reservation.transactable }
  end

  def transactable_type_id
    @reservation.try(:listing).try(:transactable_type_id)
  end

  def should_be_processed?
    @reservation.present?
  end

end
