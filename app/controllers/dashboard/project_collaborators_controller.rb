class Dashboard::ProjectCollaboratorsController < Dashboard::BaseController
  before_filter :find_transactable_type
  before_filter :find_project
  before_filter :find_project_collaborator, except: [:create]

  def create
    user = User.find_by_email(params[:email])
    @project_collaborator = @project.project_collaborators.create(user: user, approved_at: Time.zone.now)
    render_project_collaborator
  end

  def update
    @project_collaborator.update_attributes(project_collaborator_params)
    WorkflowStepJob.perform(WorkflowStep::ProjectWorkflow::CollaboratorApproved, @project_collaborator.id)
    render_project_collaborator
  end

  def destroy
    @project_collaborator.destroy
    if current_user.id == @project_collaborator.user_id
      WorkflowStepJob.perform(WorkflowStep::ProjectWorkflow::CollaboratorHasQuit, @project_collaborator.project_id, @project_collaborator.user_id)
    else
      WorkflowStepJob.perform(WorkflowStep::ProjectWorkflow::CollaboratorDeclined, @project_collaborator.project_id, @project_collaborator.user_id)
    end
    render json: { result: 'OK' }
  end

  private

  def render_project_collaborator
    html = render_to_string(partial: @project_collaborator)
    error = @project_collaborator.errors.full_messages.to_sentence
    render json: { html: html, error: error }
  end

  def find_transactable_type
    @transactable_type = ProjectType.find(params[:project_type_id])
  end

  def find_project
    @project = current_user.projects.find(params[:project_id])
  end

  def find_project_collaborator
    @project_collaborator = @project.project_collaborators.find(params[:id])
  end

  def project_collaborator_params
    params.require(:project_collaborator).permit(secured_params.project_collaborator)
  end
end
