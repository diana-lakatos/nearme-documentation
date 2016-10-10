class Utils::DefaultAlertsCreator::RfqCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_request_received_email!
    create_support_received_email!
    create_request_updated_email!
    create_support_updated_email!
    create_request_replied_email!
  end

  def create_request_received_email!
    create_alert!(associated_class: WorkflowStep::RfqWorkflow::Created, name: 'request_received', path: 'support_mailer/rfq_request_received', subject: "Your #{I18n.t('reservations.rfq_long')} has been received", alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_support_received_email!
    create_alert!(associated_class: WorkflowStep::RfqWorkflow::Created, name: 'support_received', path: 'support_mailer/rfq_support_received', subject: "{{message.full_name}} has submited a #{I18n.t('reservations.rfq_long')}", alert_type: 'email', recipient_type: 'lister')
  end

  def create_request_updated_email!
    create_alert!(associated_class: WorkflowStep::RfqWorkflow::Updated, name: 'request_received', path: 'support_mailer/rfq_request_updated', subject: "Your #{I18n.t('reservations.rfq_long')} was updated", alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_support_updated_email!
    create_alert!(associated_class: WorkflowStep::RfqWorkflow::Updated, name: 'support_received', path: 'support_mailer/rfq_support_updated', subject: "{{message.full_name}} has updated their #{I18n.t('reservations.rfq_long')}", alert_type: 'email', recipient_type: 'lister')
  end

  def create_request_replied_email!
    create_alert!(associated_class: WorkflowStep::RfqWorkflow::Replied, name: 'request_replied', path: 'support_mailer/rfq_request_replied', subject: "{{message.full_name}} replied to your #{I18n.t('reservations.rfq_long')}", alert_type: 'email', recipient_type: 'enquirer')
  end

  protected

  def workflow_type
    'request_for_quote'
  end
end
