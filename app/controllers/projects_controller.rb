class ProjectsController < ApplicationController
  layout :dashboard_or_community_layout

  before_filter :find_project, only: [:show]
  before_filter :redirect_if_draft, only: [:show]
  before_filter :build_comment, only: [:show]

  def show
    @feed = ActivityFeedService.new(@project, current_user: current_user)
    @followers = @project.feed_followers.paginate(pagination_params)
    @collaborators = @project.collaborating_users.paginate(pagination_params)
  end

  protected

  def find_project
    @project = Transactable.find(params[:id])
  end

  def redirect_if_draft
    redirect_to root_url, notice: I18n.t('draft_project') if @project.draft? && @project.creator != current_user
  end

  def build_comment
    @comment = @project.comments.build
    @comments = @project.comments.includes(:user).order('created_at DESC')
  end

  def pagination_params
    {
      page: 1,
      per_page: ActivityFeedService::Helpers::FOLLOWED_PER_PAGE
    }
  end
end
