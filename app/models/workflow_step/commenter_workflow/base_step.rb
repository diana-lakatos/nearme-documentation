class WorkflowStep::CommenterWorkflow::BaseStep < WorkflowStep::BaseStep

  attr_reader :comment_creator, :transctable_owner, :transactable

  def initialize(user_id, transactable_id)
    @comment_creator = User.find_by(id: user_id)
    @transactable = Transactable.find_by(id: transactable_id)
    @transctable_owner = @transactable.try(:creator)
  end

  def lister
    transctable_owner
  end

  def collaborators
    transactable.approved_transactable_collaborators
  end

  def data
    {
      user: comment_creator,
      transactable: transactable
    }
  end

  def workflow_type
    'commenter_workflow'
  end

  def should_be_processed?
    @transactable.present?
  end

end
