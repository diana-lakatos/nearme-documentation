class WorkflowStep::ProjectWorkflow::BaseStep < WorkflowStep::BaseStep

  def self.belongs_to_transactable_type?
    true
  end

  def initialize(project_collaborator_id)
    @project_collaborator = ProjectCollaborator.find_by(id: project_collaborator_id)
    @project = @project_collaborator.project
    @user = @project_collaborator.user
    @owner = @project.creator
  end

  def workflow_type
    'project_workflow'
  end

  def enquirer
    @user
  end

  def lister
    @owner
  end

  # project_collaborator:
  #   Project Collaborator object
  # project:
  #   Project object
  # user:
  #   User object representing the collaborator
  # owner:
  #   User object representing the project owner
  def data
    {
      project_collaborator: @project_collaborator,
      project: @project,
      user: @user,
      owner: @owner
    }
  end

  def transactable_type_id
    @project.transactable_type_id
  end

  def should_be_processed?
    @project_collaborator && @project.present?
  end

end
