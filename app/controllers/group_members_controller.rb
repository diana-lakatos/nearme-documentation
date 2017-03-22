class GroupMembersController < ApplicationController
  rescue_from GroupMember::OwnerCannotLeaveGroup, with: :owner_cannot_leave_group

  layout :dashboard_or_community_layout

  before_action :authenticate_user!
  before_filter :find_group

  def create
    raise ActiveRecord::NotFound if @group.secret?
    @membership = @group.memberships.create(user: current_user, email: current_user.email, approved_by_user_at: Time.zone.now)

    if @group.public?
      @membership.update(approved_by_owner_at: Time.zone.now)
      WorkflowStepJob.perform(WorkflowStep::GroupWorkflow::MemberJoined, @membership.id, as: current_user)
    else
      WorkflowStepJob.perform(WorkflowStep::GroupWorkflow::MemberPendingApproval, @membership.id, as: current_user)
    end

    respond_to do |format|
      format.js
    end
  end

  def accept
    @membership = @group.memberships.for_user(current_user).find(params[:id])
    @membership.update(approved_by_user_at: Time.zone.now)
    WorkflowStepJob.perform(WorkflowStep::GroupWorkflow::UserAcceptsInvitation, @membership.id, as: current_user)

    respond_to do |format|
      format.js { render :create }
      format.html do
        redirect_to profile_path(current_user, anchor: :groups), notice: t('membership_accepted')
      end
    end
  end

  def destroy
    @memberships = @group.memberships.for_user(current_user).destroy_all
    WorkflowStepJob.perform(WorkflowStep::GroupWorkflow::MemberHasQuit, @memberships.first.id, as: current_user)

    respond_to do |format|
      format.js { render :create }
      format.html do
        redirect_to profile_path(current_user, anchor: :groups), notice: t('membership_accepted')
      end
    end
  end

  protected

  def find_group
    @group = Group.find(params[:group_id]).try(:decorate)
  end

  def owner_cannot_leave_group(error)
    render json: error.message
  end
end
