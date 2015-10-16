class ProjectCollaboratorsController < ApplicationController
  layout :dashboard_or_community_layout

  before_filter :find_project

  def create
    project_collaborator = @project.project_collaborators.create(user: current_user)
    @collaborators_count = @project.reload.project_collaborators.approved.count
    WorkflowStepJob.perform(WorkflowStep::ProjectWorkflow::CollaboratorPendingApproval, project_collaborator.id)
    respond_to do |format|
      format.js { render :collaborators_button }
    end
  end

  def destroy
    @project.project_collaborators.where(user: current_user).destroy_all
    @collaborators_count = @project.reload.project_collaborators.approved.count
    respond_to do |format|
      format.js { render :collaborators_button }
    end
  end

  protected

  def find_project
    @project = Project.seek_collaborators.find(params[:project_id])
  end

end

