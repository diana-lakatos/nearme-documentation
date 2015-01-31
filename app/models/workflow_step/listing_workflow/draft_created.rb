class WorkflowStep::ListingWorkflow::DraftCreated < WorkflowStep::ListingWorkflow::BaseStep

  def data
    { user: @transactable.creator, listing: @transactable }
  end

  def should_be_processed?
    @transactable.draft.present?
  end

end

