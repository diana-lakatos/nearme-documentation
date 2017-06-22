# frozen_string_literal: true
class Utils::DefaultAlertsCreator::OrderCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    notify_host_of_marked_as_completed!
    abandoned_cart_reminder!
  end

  def notify_host_of_marked_as_completed!
    create_alert!(associated_class: WorkflowStep::OrderWorkflow::Completed, name: 'notify_host_of_marked_as_completed', path: 'order_mailer/notify_host_of_marked_as_completed', subject: '[{{platform_context.name}}] Your order has been marked as completed',  alert_type: 'email', recipient_type: 'lister')
  end

  def abandoned_cart_reminder!(enabled: false)
    create_alert!(
      associated_class: WorkflowStep::OrderWorkflow::Created,
      name: 'Abandoned cart', path: 'order_mailer/abandoned_cart',
      subject: '[{{platform_context.name}}] Would you like to finalize booking?',
      alert_type: 'email',
      recipient_type: 'enquirer',
      prevent_trigger_condition: "order.state != 'inactive'",
      delay: 120,
      enabled: enabled
    )
  end

  protected

  def workflow_type
    'order'
  end
end
