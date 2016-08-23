class WorkflowStep::GroupWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize
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
    @group.approved_members.select do |u|
      u.notification_preference.blank? ||
      u.notification_preference.email_frequency.eql?('immediately')
    end
  end

  def data
    {
      group_member: @membership,
      group: @group,
      user: @user,
      enquirer: @user,
      owner: @owner
    }
  end

  def should_be_processed?
    @membership.present? && @group.present? && @user.present? && members.any?
  end

  def workflow_type
    'group_workflow'
  end

end
