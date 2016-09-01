class WorkflowStep::CommenterWorkflow::UserCommentedOnTransactable < WorkflowStep::CommenterWorkflow::BaseStep

  def lister
    @commentable.creator
  end

  def collaborators
    @commentable.approved_transactable_collaborators
  end

  def data
    {
      user: @user,
      transactable: @commentable
    }
  end

end
