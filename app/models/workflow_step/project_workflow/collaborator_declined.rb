class WorkflowStep::ProjectWorkflow::CollaboratorDeclined < WorkflowStep::ProjectWorkflow::BaseStep

  def initialize(project_id, user_id)
    @project = Project.find_by(id: project_id)
    @user = User.find_by(id: user_id)
    @owner = @project.try(:creator)
  end

  def should_be_processed?
    @project.present? && @user.present?
  end
end

