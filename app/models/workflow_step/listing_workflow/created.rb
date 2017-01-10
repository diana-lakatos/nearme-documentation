class WorkflowStep::ListingWorkflow::Created < WorkflowStep::ListingWorkflow::BaseStep
  # user:
  #   User object
  # listing:
  #   Transactable object
  def data
    { user: @transactable.creator, listing: @transactable }
  end
end
