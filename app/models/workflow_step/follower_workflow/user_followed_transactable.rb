class WorkflowStep::FollowerWorkflow::UserFollowedTransactable < WorkflowStep::FollowerWorkflow::BaseStep

  def lister
    @followed.try(:creator)
  end

  def collaborators
    @followed.collaborators_email_recipients
  end

  def data
    {
      user: @user,
      transactable: @followed
    }
  end

end
