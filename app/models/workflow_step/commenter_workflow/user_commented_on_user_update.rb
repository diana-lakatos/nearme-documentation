class WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate < WorkflowStep::CommenterWorkflow::BaseStep

  def lister
    @commentable.followed
  end

  def data
    {
      user: @user,
      commenter: @user,
      commented_user: lister
    }
  end

end
