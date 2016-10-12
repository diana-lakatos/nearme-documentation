class Utils::DefaultAlertsCreator::InstanceAlertsCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_instance_created_email!
  end

  def create_instance_created_email!
    create_alert!(associated_class: WorkflowStep::InstanceWorkflow::Created, name: 'instance_created', path: 'post_action_mailer/instance_created', subject: 'Instance created', alert_type: 'email', recipient_type: 'enquirer')
  end

  protected

  def workflow_type
    'instance'
  end
end
