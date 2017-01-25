class Utils::DefaultAlertsCreator::PaymentGatewayCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_notify_host_about_merchant_account_approved_email!
    create_notify_host_about_merchant_account_declined_email!
    create_notify_host_about_merchant_account_requirements_email!
    create_notify_host_about_payout_failure_email!
    create_notify_enquirer_of_bank_account_creation!
  end

  def create_notify_enquirer_of_bank_account_creation!
    create_alert!(associated_class: WorkflowStep::PaymentGatewayWorkflow::BankAccountPending, name: 'notify_enquirer_of_bank_account_creation', path: 'payment_gateway_mailer/notify_enquirer_of_bank_account_creation', subject: 'Your BankAccount is pending verification', alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_notify_enquirer_of_bank_account_verification!
    create_alert!(associated_class: WorkflowStep::PaymentGatewayWorkflow::BankAccountVerified, name: 'notify_enquirer_of_bank_account_verification', path: 'payment_gateway_mailer/notify_enquirer_of_bank_account_verification', subject: 'Your BankAccount is verified', alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_notify_host_about_merchant_account_approved_email!
    create_alert!(associated_class: WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved, name: 'notify_host_about_merchant_account_approved_email', path: 'payment_gateway_mailer/notify_host_of_merchant_account_approval', subject: 'Your payout information has been approved', alert_type: 'email', recipient_type: 'lister')
  end

  def create_notify_host_about_merchant_account_declined_email!
    create_alert!(associated_class: WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined, name: 'notify_host_about_merchant_account_declined_email', path: 'payment_gateway_mailer/notify_host_of_merchant_account_declinal', subject: 'Your payout information has been declined', alert_type: 'email', recipient_type: 'lister')
  end

  def create_notify_host_about_merchant_account_requirements_email!
    create_alert!(associated_class: WorkflowStep::PaymentGatewayWorkflow::MerchantAccountPending, name: 'notify_host_about_merchant_account_requirements_email', path: 'payment_gateway_mailer/notify_host_of_merchant_account_requirements', subject: 'Please provide required information', alert_type: 'email', recipient_type: 'lister')
  end

  def create_notify_host_about_payout_failure_email!
    create_alert!(associated_class: WorkflowStep::PaymentGatewayWorkflow::DisbursementFailed, name: 'notify_host_about_payout_failure_email', path: 'payment_gateway_mailer/notify_host_about_payout_failure_email', subject: 'Automatic payout failed', alert_type: 'email', recipient_type: 'lister')
  end

  protected

  def workflow_type
    'payment_gateway'
  end
end
