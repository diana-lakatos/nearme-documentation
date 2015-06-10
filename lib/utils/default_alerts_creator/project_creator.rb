class Utils::DefaultAlertsCreator::ProjectCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    create_project_owner_added_collaborator_email!
  end

  def create_project_owner_added_collaborator_email!
    create_alert!({associated_class: WorkflowStep::ProjectWorkflow::CollaboratorAddedByProjectOwner, name: 'project_owner_added_collaborator_email', path: 'project_mailer/project_owner_added_collaborator_email', subject: '{{user.first_name}}, you are now collaborator of {{ project.name }}', alert_type: 'email', recipient_type: 'enquirer'})
  end

  protected

  def workflow_type
    'project_workflow'
  end

end

