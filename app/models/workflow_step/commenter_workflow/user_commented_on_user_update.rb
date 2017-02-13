class WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate < WorkflowStep::CommenterWorkflow::BaseStep
  def lister
    @commentable.followed
  end

  def data
    {
      user: lister,
      commenter: enquirer,
      commented_user: lister,
      comment_contexts: @commentable.event_source.topics.map(&:name)
    }
  end
end
