class WorkflowStep::ListingWorkflow::Created < WorkflowStep::ListingWorkflow::BaseStep

  def data
    { user: @transactable.creator, listing: @transactable }
  end

end

