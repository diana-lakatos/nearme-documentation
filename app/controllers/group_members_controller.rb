class GroupMembersController < ApplicationController
  rescue_from GroupMember::OwnerCannotLeaveGroup, with: :owner_cannot_leave_group

  layout :dashboard_or_community_layout

  before_action :authenticate_user!
  before_filter :find_group

  def create
    @membership = @group.memberships.create(user: current_user, email: current_user.email, approved_by_user_at: Time.now)

    if @group.public?
      @membership.update_column(:approved_by_owner_at, Time.now)
    else
      WorkflowStepJob.perform(WorkflowStep::GroupWorkflow::MemberPendingApproval, @membership.id)
    end

    respond_to do |format|
      format.js
    end
  end

  def accept
    @membership = @group.memberships.for_user(current_user).find(params[:id])
    @membership.update_column(:approved_by_user_at, Time.now)

    respond_to do |format|
      format.js { render :create }
      format.html {
        redirect_to profile_path(current_user, anchor: :groups), notice: t('membership_accepted')
      }
    end
  end

  def destroy
    @group.memberships.for_user(current_user).destroy_all

    respond_to do |format|
      format.js { render :create }
      format.html {
        redirect_to profile_path(current_user, anchor: :groups), notice: t('membership_accepted')
      }
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
