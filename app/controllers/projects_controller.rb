class ProjectsController < ApplicationController
  layout :dashboard_or_community_layout

  before_filter :find_project, only: [:show]
  before_filter :build_comment, only: [:show]

  def show
    @feed = ActivityFeedService.new(@project)
    @followers = @project.feed_followers.paginate(page: 1, per_page: ActivityFeedService::Helpers::EVENTS_PER_PAGE)
  end

  protected

  def find_project
    @project = Project.find(params[:id])
  end

  def build_comment
    @comment = @project.comments.build
    @comments = @project.comments.includes(:user).order("created_at DESC")
  end
end

