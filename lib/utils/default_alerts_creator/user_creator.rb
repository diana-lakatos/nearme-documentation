class Utils::DefaultAlertsCreator::UserCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_unread_messages_email!
    create_user_promoted_email!
    create_profile_approved!
  end

  def create_profile_approved!
    create_alert!(associated_class: WorkflowStep::UserWorkflow::ProfileApproved, name: 'notify user of profile approved', path: 'user_mailer/profile_approved', subject: "Your profile has been approved!", alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_unread_messages_email!
    create_alert!(associated_class: WorkflowStep::UserWorkflow::UnreadMessages, name: 'unread_messages_for_user', path: 'user_mailer/notify_about_unread_messages', subject: "{{'user_workflow.unread_messages.unread_messages_subject' | translate}}", alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_user_promoted_email!
    create_alert!(associated_class: WorkflowStep::UserWorkflow::PromotedToAdmin, name: 'user_promoted_to_instance_admin_email', path: 'user_mailer/user_promoted_to_instance_admin_email', subject: "You've become an Admin of {{ platform_context.name }}", alert_type: 'email', recipient_type: 'enquirer')
  end

  protected

  def workflow_type
    'user'
  end
end
