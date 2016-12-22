class Utils::DefaultAlertsCreator::OrderItemCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
  end

  def create_notify_lister_updated_order_item!
    create_alert!(associated_class: WorkflowStep::OrderItemWorkflow::Updated, name: 'notify_lister_updated_order_item', path: 'order_item_mailer/notify_lister_updated_order_item', subject: '[{{platform_context.name}}] {{enquirer.first_name}} has updated invoice!', alert_type: 'email', recipient_type: 'lister')
  end

  def create_notify_lister_created_order_item!
    create_alert!(associated_class: WorkflowStep::OrderItemWorkflow::Created, name: 'notify_lister_created_order_item', path: 'order_item_mailer/notify_lister_created_order_item', subject: '[{{platform_context.name}}] {{enquirer.first_name}} has submitted invoice!', alert_type: 'email', recipient_type: 'lister')
  end

  def create_notify_enquirer_rejected_order_item!
    create_alert!(associated_class: WorkflowStep::OrderItemWorkflow::Rejected, name: 'notify_enquirer_rejected_order_item', path: 'order_item_mailer/notify_enquirer_rejected_order_item', subject: '[{{platform_context.name}}] {{lister.first_name}} has rejected invoice!', alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_notify_enquirer_approved_order_item!
    create_alert!(associated_class: WorkflowStep::OrderItemWorkflow::Approved, name: 'notify_enquirer_approved_order_item', path: 'order_item_mailer/notify_enquirer_approved_order_item', subject: '[{{platform_context.name}}] {{lister.first_name}} has approved invoice!', alert_type: 'email', recipient_type: 'enquirer')
  end

  protected

  def workflow_type
    'order_item'
  end
end
