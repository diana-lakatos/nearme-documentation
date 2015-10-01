class ProjectCollaboratorsController < ApplicationController
  layout :dashboard_or_community_layout

  before_filter :find_project

  def create
    @project.project_collaborators.create(user: current_user)
    redirect_to project_path(@project)
  end

  def destroy
    @project.project_collaborators.where(user: current_user).destroy_all
    redirect_to project_path(@project)
  end

  protected

  def find_project
    @project = Project.seek_collaborators.find(params[:project_id])
  end

end

