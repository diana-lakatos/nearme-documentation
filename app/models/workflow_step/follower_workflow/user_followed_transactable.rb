class WorkflowStep::FollowerWorkflow::UserFollowedTransactable < WorkflowStep::FollowerWorkflow::BaseStep

  def lister
    @followed.try(:creator)
  end

  def collaborators
    @followed.approved_transactable_collaborators
  end

  def data
    {
      user: @user,
      transactable: @followed
    }
  end

end
