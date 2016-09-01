class Utils::DefaultAlertsCreator::CommenterCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    user_commented_on_transactable!
  end

  def user_commented_on_transactable!
    create_alert!({associated_class: WorkflowStep::CommenterWorkflow::UserCommentedOnTransactable, name: 'user_commented_on_transactable', path: 'user_mailer/user_commented_on_transactable', subject: "{{ user.name }} commented on {{ transactable.name }}", alert_type: 'email', recipient_type: 'lister', bcc_type: 'collaborators'})
  end

  protected

  def workflow_type
    'commenter_workflow'
  end

end
