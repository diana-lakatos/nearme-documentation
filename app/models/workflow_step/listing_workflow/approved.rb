class WorkflowStep::ListingWorkflow::Approved < WorkflowStep::ListingWorkflow::BaseStep

  def should_be_processed?
    @transactable.is_trusted?
  end

end

