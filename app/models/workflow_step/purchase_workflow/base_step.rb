class WorkflowStep::PurchaseWorkflow::BaseStep < WorkflowStep::BaseStep

  def self.belongs_to_transactable_type?
    true
  end

  def initialize(pruchase_id)
    @pruchase = Order.find_by_id(pruchase_id)
  end

  def workflow_type
    'pruchase'
  end

  def lister
    @pruchase.host
  end

  def enquirer
    @pruchase.owner
  end

  # pruchase:
  #   Reservation object
  # user:
  #   listing User object
  # host:
  #   enquiring User object
  # listing:
  #   Transactable object
  def data
    { pruchase: @pruchase, user: lister, host: enquirer, listing: @pruchase.transactable }
  end

  def transactable_type_id
    @pruchase.try(:listing).try(:transactable_type_id)
  end

  def should_be_processed?
    @pruchase.present?
  end

end
