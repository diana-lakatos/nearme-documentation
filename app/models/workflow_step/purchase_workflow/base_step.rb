class WorkflowStep::PurchaseWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    true
  end

  def initialize(purchase_id)
    @purchase = Order.find_by_id(purchase_id)
  end

  def workflow_type
    'purchase'
  end

  def lister
    @purchase.host
  end

  def enquirer
    @purchase.owner
  end

  # purchase:
  #   Reservation object
  # lister:
  #   listing User object
  # enquirer:
  #   enquiring User object
  # listing:
  #   Transactable object
  def data
    { purchase: @purchase, lister: lister, enquirer: enquirer, listing: @purchase.transactable }
  end

  def transactable_type_id
    @purchase.try(:listing).try(:transactable_type_id)
  end

  def should_be_processed?
    @purchase.present?
  end
end
