class WorkflowStep::CollaboratorWorkflow::CollaboratorHasQuit < WorkflowStep::CollaboratorWorkflow::BaseStep

  def initialize(transactable_id, user_id)
    @transactable = Transactable.find_by(id: transactable_id)
    @enquirer = User.find_by(id: user_id)
    @lister = @transactable.try(:creator)
  end

  def should_be_processed?
    transactable.present? && enquirer.present?
  end
end
