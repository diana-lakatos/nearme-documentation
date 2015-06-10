class ProjectsController < ApplicationController
  layout :dashboard_or_community_layout

  before_filter :find_project, only: [:show]
  before_filter :build_comment, only: [:show]
  before_filter :find_project_collaborator, only: [:show]

  def show
    @feed = ActivityFeedService.new(@project)
    @followers = @project.feed_followers(params)
  end

  protected

  def find_project
    @project = Project.find(params[:id])
  end

  def build_comment
    @comment = @project.comments.build
    @comments = @project.comments.includes(:user).order("created_at DESC")
  end

  def find_project_collaborator
    @project_collaborator = @project.project_collaborators.where(user: current_user).first
  end
end

