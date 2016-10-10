class WorkflowStep::CommenterWorkflow::UserCommentedOnGroup < WorkflowStep::CommenterWorkflow::BaseStep
  def lister
    @commentable.try(:creator)
  end

  def members
    @commentable.members_email_recipients
  end

  def data
    {
      user: @user,
      commenter: @user,
      group: @commentable
    }
  end
end
