class WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate < WorkflowStep::CommenterWorkflow::BaseStep
  def lister
    @commentable.followed
  end

  def data
    {
      user: lister,
      comment_id: @comment.id,
      commenter: enquirer,
      commented_user: lister,
      comment_contexts: @commentable.event_source.topics.map(&:name)
    }
  end
end
