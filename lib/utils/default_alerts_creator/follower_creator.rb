class Utils::DefaultAlertsCreator::FollowerCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_user_followed_transactable!
    create_user_followed_user!
  end

  def create_user_followed_transactable!
    create_alert!(associated_class: WorkflowStep::FollowerWorkflow::UserFollowedTransactable, name: 'notify_collaborators_user_followed_transactable', path: 'user_mailer/user_followed_transactable', subject: '{{ user.name }} started following {{ transactable.name }}', alert_type: 'email', recipient_type: nil, bcc_type: 'collaborators')
    create_alert!(associated_class: WorkflowStep::FollowerWorkflow::UserFollowedTransactable, name: 'notify_creator_user_followed_transactable', path: 'user_mailer/user_followed_transactable', subject: '{{ user.name }} started following {{ transactable.name }}', alert_type: 'email', recipient_type: 'lister')
  end

  def create_user_followed_user!
    create_alert!(associated_class: WorkflowStep::FollowerWorkflow::UserFollowedUser, name: 'user_followed_user', path: 'user_mailer/user_followed_user', subject: '{{ user.name }} started following You', alert_type: 'email', recipient_type: 'lister')
  end

  protected

  def workflow_type
    'follower_workflow'
  end
end
