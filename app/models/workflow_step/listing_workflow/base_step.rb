class WorkflowStep::ListingWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    true
  end

  def initialize(transactable_id, approval_request_id = nil)
    @transactable = Transactable.find_by_id(transactable_id)

    # Silencing errors if for example the transactable is deleted before the email is sent out;
    # the email will not be sent as should_be_processed? will return false
    if @transactable.present?
      @approval_request = @transactable.approval_requests.find(approval_request_id) if approval_request_id

      @enquirer = @transactable.creator
      @lister = @transactable.creator
    end
  end

  def workflow_type
    'listing'
  end

  def collaborators
    transactable.try(:collaborators_email_recipients)
  end

  # listing:
  #   Transactable object
  def data
    {
      listing: @transactable,
      transactable: @transactable,
      enquirer: nil,
      lister: lister,
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
