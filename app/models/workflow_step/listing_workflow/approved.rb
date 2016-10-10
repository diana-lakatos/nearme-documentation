class WorkflowStep::ListingWorkflow::Approved < WorkflowStep::ListingWorkflow::BaseStep
  def should_be_processed?
    @transactable.try(:is_trusted?)
  end
end
