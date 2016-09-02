class WorkflowStep::GroupWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize(membership_id)
    @membership = GroupMember.find_by(id: membership_id)
    @group = @membership.try(:group)
    @user = @membership.try(:user)
    @owner = @group.try(:creator)
  end

  def enquirer
    @user
  end

  def lister
    @owner
  end

  def members
    @group.members_email_recipients
  end

  def data
    {
      group_member: @membership,
      group: @group,
      user: @user,
      enquirer: @user,
      lister: @owner,
      owner: @owner
    }
  end

  def should_be_processed?
    @membership.present?
  end

  def workflow_type
    'group_workflow'
  end

end
