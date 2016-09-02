class WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate < WorkflowStep::CommenterWorkflow::BaseStep

  def lister
    @commentable
  end

  def data
    {
      user: @user,
      commented_user: @commentable
    }
  end

end
