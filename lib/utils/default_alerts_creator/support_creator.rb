class Utils::DefaultAlertsCreator::SupportCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_request_received_email!
    create_support_received_email!
    create_request_updated_email!
    create_support_updated_email!
    create_request_replied_email!
  end

  def create_request_received_email!
    create_alert!(associated_class: WorkflowStep::SupportWorkflow::Created, name: 'request_received', path: 'support_mailer/request_received', subject: "#{subject_prefix} Your support request has been received", alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_support_received_email!
    create_alert!(associated_class: WorkflowStep::SupportWorkflow::Created, name: 'support_received', path: 'support_mailer/support_received', subject: "#{subject_prefix} {{message.full_name}} has submited a support request", alert_type: 'email', recipient_type: 'Administrator')
  end

  def create_request_updated_email!
    create_alert!(associated_class: WorkflowStep::SupportWorkflow::Updated, name: 'request_received', path: 'support_mailer/request_updated', subject: "#{subject_prefix} Your support request was updated", alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_support_updated_email!
    create_alert!(associated_class: WorkflowStep::SupportWorkflow::Updated, name: 'support_received', path: 'support_mailer/support_updated', subject: "#{subject_prefix} {{message.full_name}} has updated their support request", alert_type: 'email', recipient_type: 'Administrator')
  end

  def create_request_replied_email!
    create_alert!(associated_class: WorkflowStep::SupportWorkflow::Replied, name: 'request_replied', path: 'support_mailer/request_replied', subject: "#{subject_prefix} {{message.full_name}} replied to your support request", alert_type: 'email', recipient_type: 'enquirer')
  end

  protected

  def workflow_type
    'support'
  end

  def subject_prefix
    '[Ticket Support {{ticket.id}}] {{platform_context.name}} -'
  end
end
