class WorkflowStep::CollaboratorWorkflow::CollaboratorAddedByTransactableOwner < WorkflowStep::CollaboratorWorkflow::BaseStep
  def should_be_processed?
    super && !@transactable_collaborator.approved_by_user?
  end
end

