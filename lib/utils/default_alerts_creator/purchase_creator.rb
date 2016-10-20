class Utils::DefaultAlertsCreator::PurchaseCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    notify_guest_of_confirmation!
    notify_host_of_confirmation!
    notify_guest_of_rejection!
    notify_host_of_rejection!
  end

  def notify_host_of_confirmation!
    create_alert!(associated_class: WorkflowStep::PurchaseWorkflow::ManuallyConfirmed, name: 'notify_host_of_confirmation', path: 'purchase_mailer/notify_host_of_confirmation', subject: '[{{platform_context.name}}] Thanks for confirming!', alert_type: 'email', recipient_type: 'lister')
  end

  def notify_guest_of_confirmation!
    create_alert!(associated_class: WorkflowStep::PurchaseWorkflow::ManuallyConfirmed, name: 'notify_guest_of_confirmation', path: 'purchase_mailer/notify_guest_of_confirmation', subject: '[{{platform_context.name}}] Your purchase of {{ listing.name }} has been confirmed!', alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_guest_of_rejection!
    create_alert!(associated_class: WorkflowStep::PurchaseWorkflow::Rejected, name: 'notify_guest_of_rejection', path: 'purchase_mailer/notify_guest_of_rejection', subject: '[{{platform_context.name}}] Your purchase of {{ listing.name }} has been rejected!', alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_host_of_rejection!
    create_alert!(associated_class: WorkflowStep::PurchaseWorkflow::Rejected, name: 'notify_host_of_rejection', path: 'purchase_mailer/notify_host_of_rejection', subject: '[{{platform_context.name}}] Your have rejected a purchase of {{ listing.name }}', alert_type: 'email', recipient_type: 'lister')
  end

  protected

  def workflow_type
    'purchase'
  end
end
