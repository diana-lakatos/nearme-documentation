class Utils::DefaultAlertsCreator::OrderCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    notify_host_of_marked_as_completed!
  end

  def notify_host_of_marked_as_completed!
    create_alert!(associated_class: WorkflowStep::OrderWorkflow::Completed, name: 'notify_host_of_marked_as_completed', path: 'order_mailer/notify_host_of_marked_as_completed', subject: '[{{platform_context.name}}] Your order has been marked as completed',  alert_type: 'email', recipient_type: 'lister')
  end

  protected

  def workflow_type
    'order'
  end
end
