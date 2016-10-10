class WorkflowStep::GroupWorkflow::MemberDeclined < WorkflowStep::GroupWorkflow::BaseStep
  def initialize(membership_id)
    @membership = GroupMember.with_deleted.find_by(id: membership_id)
    @group = @membership.try(:group)
    @user = @membership.try(:user)
    @owner = @group.try(:creator)
  end
end
