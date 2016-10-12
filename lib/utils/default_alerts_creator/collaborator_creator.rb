class Utils::DefaultAlertsCreator::CollaboratorCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_project_owner_added_collaborator_email!
    create_pending_approval_email!
    create_collaborator_approved_email!
    create_collaborator_declined_email!
    create_collaborator_has_quit_email!
  end

  def create_project_owner_added_collaborator_email!
    create_alert!(associated_class: WorkflowStep::CollaboratorWorkflow::CollaboratorAddedByTransactableOwner, name: 'transactable_owner_added_collaborator_email', path: 'transactable_mailer/transactable_owner_added_collaborator_email', subject: "You're invited to join {{ transactable.name }}", alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_pending_approval_email!
    create_alert!(associated_class: WorkflowStep::CollaboratorWorkflow::CollaboratorPendingApproval, name: 'notify transactable owner of pending request', path: 'transactable_mailer/pending_approval', subject: 'New request to join {{ transactable.name }}', alert_type: 'email', recipient_type: 'lister', delay: 0)
  end

  def create_collaborator_approved_email!
    create_alert!(associated_class: WorkflowStep::CollaboratorWorkflow::CollaboratorApproved, name: 'collaborator approved email', path: 'transactable_mailer/collaborator_approved', subject: "You've been approved as a collaborator on {{ transactable.name }}", alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_collaborator_declined_email!
    create_alert!(associated_class: WorkflowStep::CollaboratorWorkflow::CollaboratorDeclined, name: 'collaborator declined email', path: 'transactable_mailer/collaborator_declined', subject: 'Your request to collaborate on {{ transactable.name }} has been declined', alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_collaborator_has_quit_email!
    create_alert!(associated_class: WorkflowStep::CollaboratorWorkflow::CollaboratorHasQuit, name: 'collaborator has quit email', path: 'transactable_mailer/collaborator_has_quit', subject: '{{lister.first_name}}, {{ enquirer.first_name }} decided to be no longer collaborator on {{ transactable.name }}', alert_type: 'email', recipient_type: 'lister')
  end

  protected

  def workflow_type
    'collaborator_workflow'
  end
end
