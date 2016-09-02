class WorkflowStep::CommenterWorkflow::UserCommentedOnTransactable < WorkflowStep::CommenterWorkflow::BaseStep

  def lister
    @commentable.creator
  end

  def collaborators
    @commentable.collaborators_email_recipients
  end

  def data
    {
      user: @user,
      transactable: @commentable
    }
  end

end
