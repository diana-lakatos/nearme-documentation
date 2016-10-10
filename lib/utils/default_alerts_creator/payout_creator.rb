class Utils::DefaultAlertsCreator::PayoutCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_notify_host_of_no_pyout_option_email!
    create_notify_host_of_no_pyout_option_sms!
  end

  def create_notify_host_of_no_pyout_option_email!
    create_alert!(associated_class: WorkflowStep::PayoutWorkflow::NoPayoutOption, name: 'Notify host of no payout option', path: 'company_mailer/notify_host_of_no_payout_option', subject: 'No payout option', alert_type: 'email', recipient_type: 'lister')
  end

  def create_notify_host_of_no_pyout_option_sms!
    create_alert!(associated_class: WorkflowStep::PayoutWorkflow::NoPayoutOption, name: 'Notify host of no payout option', path: 'company_sms_notifier/notify_host_of_no_payout_option', alert_type: 'sms', recipient_type: 'lister')
  end

  protected

  def workflow_type
    'payout'
  end
end
