class WorkflowStep::CollaboratorWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    true
  end

  def initialize(transactable_collaborator_id)
    @transactable_collaborator = TransactableCollaborator.find_by(id: transactable_collaborator_id)
    @transactable = @transactable_collaborator.try(:transactable)
    @enquirer = @transactable_collaborator.try(:user)
    @lister = @transactable.try(:creator)
  end

  def workflow_type
    'collaborator_workflow'
  end

  # transactable_collaborator:
  #   Transactable Collaborator object
  # transactable:
  #   Transactable object
  # enquirer:
  #   User object representing the collaborator
  # lister:
  #   User object representing the transactable owner
  def data
    {
      transactable_collaborator: @transactable_collaborator,
      transactable: transactable,
      enquirer: enquirer,
      lister: lister
    }
  end

  def transactable_type_id
    transactable.transactable_type_id
  end

  def should_be_processed?
    @transactable_collaborator.present? && transactable.present? && enquirer.present?
  end

  def workflow_triggered_by
    enquirer
  end
end
