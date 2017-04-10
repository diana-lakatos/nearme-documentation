class WorkflowStep::ListingWorkflow::Created < WorkflowStep::ListingWorkflow::BaseStep
  # user:
  #   User object
  # listing:
  #   Transactable object
  def data
    # if @transactable is blank, step will not be invoked because of should_be_processed?
    # but the event will still be serialized
    { user: @transactable.try(:creator), listing: @transactable }
  end
end
