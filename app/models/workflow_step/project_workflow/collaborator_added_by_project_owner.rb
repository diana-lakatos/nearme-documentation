class WorkflowStep::ProjectWorkflow::CollaboratorAddedByProjectOwner < WorkflowStep::ProjectWorkflow::BaseStep
  def should_be_processed?
    super && @project_collaborator.approved?
  end
end

