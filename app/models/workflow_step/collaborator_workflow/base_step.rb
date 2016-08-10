class WorkflowStep::CollaboratorWorkflow::BaseStep < WorkflowStep::BaseStep

  def self.belongs_to_transactable_type?
    true
  end

  def initialize(transactable_collaborator_id)
    @transactable_collaborator = TransactableCollaborator.find_by(id: transactable_collaborator_id)
    @transactable = @transactable_collaborator.try(:transactable)
    @user = @transactable_collaborator.try(:user)
    @owner = @transactable.try(:creator)
  end

  def workflow_type
    'collaborator_workflow'
  end

  def enquirer
    @user
  end

  def lister
    @owner
  end

  def transactable
    @transactable
  end

  # transactable_collaborator:
  #   Transactable Collaborator object
  # transactable:
  #   Transactable object
  # user:
  #   User object representing the collaborator
  # owner:
  #   User object representing the transactable owner
  def data
    {
      transactable_collaborator: @transactable_collaborator,
      transactable: @transactable,
      user: @user,
      enquirer: @user,
      lister: @owner,
      owner: @owner
    }
  end

  def transactable_type_id
    @transactable.transactable_type_id
  end

  def should_be_processed?
    @transactable_collaborator.present? && @transactable.present? && @user.present?
  end

end
