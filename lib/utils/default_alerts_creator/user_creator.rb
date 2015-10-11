class Utils::DefaultAlertsCreator::UserCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    create_unread_messages_email!
  end

  def create_unread_messages_email!
    create_alert!({associated_class: WorkflowStep::UserWorkflow::UnreadMessages, name: 'unread_messages_for_user', path: 'user_mailer/notify_about_unread_messages', subject: "{{'user_workflow.unread_messages.unread_messages_subject' | translate}}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  protected

  def workflow_type
    'user'
  end

end

