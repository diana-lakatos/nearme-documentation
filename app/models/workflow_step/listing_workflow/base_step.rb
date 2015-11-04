class WorkflowStep::ListingWorkflow::BaseStep < WorkflowStep::BaseStep

  def self.belongs_to_transactable_type?
    true
  end

  def initialize(transactable_id, approval_request_id = nil)
    @transactable = Transactable.find_by_id(transactable_id)
    @approval_request = @transactable.approval_requests.find(approval_request_id) if approval_request_id
  end

  def workflow_type
    'listing'
  end

  def enquirer
    @transactable.creator
  end

  def lister
    @transactable.creator
  end

  # listing:
  #   Transactable object
  def data
    {
      listing: @transactable,
      approval_request: @approval_request
    }
  end

  def transactable_type_id
    @transactable.transactable_type_id
  end

  def should_be_processed?
    @transactable.present?
  end

end
