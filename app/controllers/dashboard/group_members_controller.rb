class Dashboard::GroupMembersController < Dashboard::BaseController
  rescue_from GroupMember::OwnerCannotLeaveGroup, with: :owner_cannot_leave_group
  rescue_from GroupMember::OwnerCannotLoseModerateRights, with: :owner_cannot_lose_moderate_rights

  before_filter :find_group
  before_filter :find_membership, except: [:index, :create]

  def index
    @members = @group.memberships.by_phrase(params[:phrase])

    respond_to do |format|
      format.js {
        render json: { html: render_to_string(partial: @members) }
      }
    end
  end

  def destroy
    @membership.destroy
    if current_user.id == @membership.user_id
      WorkflowStepJob.perform(WorkflowStep::GroupWorkflow::MemberHasQuit, @membership.group_id, @membership.user_id)
    else
      WorkflowStepJob.perform(WorkflowStep::GroupWorkflow::MemberDeclined, @membership.group_id, @membership.user_id)
    end
    render json: { result: 'OK' }
  end

  def approve
    @membership.update(approved_by_owner_at: Time.zone.now)
    WorkflowStepJob.perform(WorkflowStep::GroupWorkflow::MemberApproved, @membership.id)
    render_membership
  end

  def moderate
    @membership.toggle!(:moderator)
    render_membership
  end

  private

  def render_membership
    html = render_to_string(partial: @membership)
    error = @membership.errors.full_messages.to_sentence
    render json: { html: html, error: error }
  end

  def find_group
    @group = current_user.moderated_groups.find(params[:group_id]).try(:decorate)
  end

  def find_membership
    @membership = @group.memberships.find(params[:id])
  end

  def group_member_params
    params.require(:group_member).permit(secured_params.group_member)
  end

  def owner_cannot_leave_group(error)
    render json: error.message
  end

  def owner_cannot_lose_moderate_rights(error)
    render json: error.message
  end
end
