class WorkflowStep::GroupWorkflow::MemberDeclined < WorkflowStep::GroupWorkflow::BaseStep

  def initialize(group_id, user_id)
    @group = Group.find_by(id: group_id)
    @user = User.find_by(id: user_id)
    @owner = @group.try(:creator)
  end

  def should_be_processed?
    @group.present? && @user.present?
  end

end
