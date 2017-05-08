# frozen_string_literal: true
class Utils::DefaultAlertsCreator::UserMessageCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_user_transactable_message_from_lister_email!
    create_user_transactable_message_from_enquirer_email!
    create_user_message_created_sms!
  end

  def create_user_transactable_message_from_lister_email!
    create_alert!(associated_class: WorkflowStep::UserMessageWorkflow::TransactableMessageFromLister, name: 'create_user_message_from_lister_email', path: 'user_message_mailer/email_message_from_host', subject: '[{{platform_context.name}}] You received a message!', alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_user_transactable_message_from_enquirer_email!
    create_alert!(associated_class: WorkflowStep::UserMessageWorkflow::TransactableMessageFromEnquirer, name: 'create_user_message_from_lister_email', path: 'user_message_mailer/email_message_from_guest', subject: '[{{platform_context.name}}] You received a message!', alert_type: 'email', recipient_type: 'lister')
  end

  def create_user_message_created_sms!
    create_alert!(associated_class: WorkflowStep::UserMessageWorkflow::Created, name: 'create_user_message_from_enquirer_sms', path: 'user_message_sms_notifier/notify_user_about_new_message', alert_type: 'sms', recipient_type: 'lister')
  end

  def create_user_message_created!
    create_alert!(associated_class: WorkflowStep::UserMessageWorkflow::Created, name: 'create_user_message_from_lister_email', path: 'user_message_mailer/notify_user_about_new_message', subject: '[{{platform_context.name}}] You received a message!', alert_type: 'email', recipient_type: 'lister')
  end

  protected

  def workflow_type
    'user_message'
  end
end
