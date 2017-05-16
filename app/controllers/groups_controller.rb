class GroupsController < ApplicationController
  layout :dashboard_or_community_layout

  before_filter :find_group, only: [:show]
  before_filter :redirect_if_draft, only: [:show]
  before_filter :find_membership, only: [:show]

  def show
    @feed = ActivityFeedService.new(@group, current_user: current_user)
    @members = @group.approved_members.custom_order("", current_user).paginate(paginate_params)
    @transactables = @group.transactables.active.paginate(paginate_params)
    respond_to :html
  end

  protected

  def find_membership
    if current_user.present?
      @membership = @group.memberships.for_user(current_user).first
    end
  end

  def find_group
    @group = Group.find(params[:id]).try(:decorate)
  end

  def redirect_if_draft
    redirect_to root_url, notice: I18n.t('draft_project') if @group.draft? && @group.creator != current_user
  end

  def paginate_params
    {
      page: 1,
      per_page: ActivityFeedService::Helpers::FOLLOWED_PER_PAGE
    }
  end
end
