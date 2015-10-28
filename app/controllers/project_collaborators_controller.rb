class ProjectCollaboratorsController < ApplicationController
  layout :dashboard_or_community_layout

  before_filter :find_project, except: [:create]
  before_action :authenticate_user!

  def create
    @project = Project.seek_collaborators.find(params[:project_id])
    project_collaborator = @project.project_collaborators.create(user: current_user, approved_by_user_at: Time.now)
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
      format.html { redirect_to profile_path(current_user, anchor: :projects), notice: t('collaboration_cancelled') }
    end
  end

  def accept
    project_collaboration = @project.project_collaborators.where(user: current_user).find(params[:id])
    project_collaboration.approve_by_user!
    redirect_to profile_path(current_user, anchor: :projects), notice: t('collaboration_accepted')
  end

  protected

  def find_project
    @project = Project.find(params[:project_id])
  end

end

