class Utils::DefaultAlertsCreator::ProjectCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    create_project_owner_added_collaborator_email!
    create_pending_approval_email!
    create_collaborator_approved_email!
    create_collaborator_declined_email!
    create_collaborator_has_quit_email!
  end

  def create_project_owner_added_collaborator_email!
    create_alert!({associated_class: WorkflowStep::ProjectWorkflow::CollaboratorAddedByProjectOwner, name: 'project_owner_added_collaborator_email', path: 'project_mailer/project_owner_added_collaborator_email', subject: '{{user.first_name}}, you are now collaborator of {{ project.name }}', alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_pending_approval_email!
    create_alert!({associated_class: WorkflowStep::ProjectWorkflow::CollaboratorPendingApproval, name: 'notify project owner of pending request', path: 'project_mailer/pending_approval', subject: '{{owner.first_name}}, you have pending request for {{ project.name }} from {{ user.first_name }}', alert_type: 'email', recipient_type: 'lister', delay: 2})
  end

  def create_collaborator_approved_email!
    create_alert!({associated_class: WorkflowStep::ProjectWorkflow::CollaboratorApproved, name: 'collaborator approved email', path: 'project_mailer/collaborator_approved', subject: '{{user.first_name}}, you are now collaborator of {{ project.name }}', alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_collaborator_declined_email!
    create_alert!({associated_class: WorkflowStep::ProjectWorkflow::CollaboratorDeclined, name: 'collaborator declined email', path: 'project_mailer/collaborator_declined', subject: '{{user.first_name}}, you were declined to become collaborator of {{ project.name }}', alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_collaborator_has_quit_email!
    create_alert!({associated_class: WorkflowStep::ProjectWorkflow::CollaboratorHasQuit, name: 'collaborator has quitted email', path: 'project_mailer/collaborator_has_quit', subject: '{{owner.first_name}}, {{ user.first_name }} decided to be no longer collaborator of {{ project.name }}', alert_type: 'email', recipient_type: 'lister'})
  end

  protected

  def workflow_type
    'project_workflow'
  end

end

