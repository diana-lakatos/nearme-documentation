class Utils::DefaultAlertsCreator::CommenterCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    user_commented_on_user_update!
    user_commented_on_transactable!
    user_commented_on_group!
  end

  def user_commented_on_user_update!
    create_alert!(associated_class: WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate, name: 'user_commented_on_user_update', path: 'user_mailer/user_commented_on_user_update', subject: '{{ commenter.name }} commented on Update', alert_type: 'email', recipient_type: 'lister')
  end

  def user_commented_on_transactable!
    create_alert!(associated_class: WorkflowStep::CommenterWorkflow::UserCommentedOnTransactable, name: 'user_commented_on_transactable', path: 'user_mailer/user_commented_on_transactable', subject: '{{ commenter.name }} commented on {{ transactable.name }}', alert_type: 'email', recipient_type: 'lister')
  end

  def user_commented_on_group!
    create_alert!(associated_class: WorkflowStep::CommenterWorkflow::UserCommentedOnGroup, name: 'notify_members_user_commented_on_group', path: 'user_mailer/user_commented_on_group', subject: '{{ commenter.name }} commented on {{ group.name }}', alert_type: 'email', recipient_type: nil, bcc_type: 'members')
    create_alert!(associated_class: WorkflowStep::CommenterWorkflow::UserCommentedOnGroup, name: 'notify_creator_user_commented_on_group', path: 'user_mailer/user_commented_on_group', subject: '{{ commenter.name }} commented on {{ group.name }}', alert_type: 'email', recipient_type: 'lister')
  end

  protected

  def workflow_type
    'commenter_workflow'
  end
end
