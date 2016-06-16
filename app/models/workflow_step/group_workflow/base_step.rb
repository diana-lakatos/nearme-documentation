class WorkflowStep::GroupWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize(group_member_id)
    @group_member = GroupMember.find_by(id: group_member_id)

    @group = @group_member.try(:group)
    @user = @group_member.try(:user)
    @owner = @group.try(:creator)
  end

  def enquirer
    @user
  end

  def lister
    @owner
  end

  def data
    {
      group_member: @group_member,
      group: @group,
      user: @user,
      enquirer: @user,
      owner: @owner
    }
  end

  def should_be_processed?
    @group_member.present? && @group.present? && @user.present?
  end

  def workflow_type
    'group_workflow'
  end

end
