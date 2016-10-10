class WorkflowStep::ListingWorkflow::DraftCreated < WorkflowStep::ListingWorkflow::BaseStep
  # user:
  #   creator User object
  # listing:
  #   Transactable object
  def data
    { user: @transactable.creator, listing: @transactable }
  end

  def should_be_processed?
    @transactable.try(:draft).present?
  end
end
