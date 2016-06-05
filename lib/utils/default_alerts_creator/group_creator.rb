class Utils::DefaultAlertsCreator::GroupCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    create_group_owner_added_collaborator_email!
    create_pending_approval_email!
    create_member_approved_email!
    create_member_declined_email!
    create_member_has_quit_email!
  end

  def create_group_owner_added_collaborator_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberAddedByGroupOwner, name: 'group_owner_added_member_email', path: 'group_mailer/group_owner_added_member_email', subject: "You're invited to join {{ group.name }}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_pending_approval_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberPendingApproval, name: 'notify group owner of pending request', path: 'group_mailer/pending_approval', subject: 'New request to join your {{ group.name }} group', alert_type: 'email', recipient_type: 'lister', delay: 2})
  end

  def create_member_approved_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberApproved, name: 'member approved email', path: 'group_mailer/member_approved', subject: "You've been approved as a group member on {{ group.name }}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_member_declined_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberDeclined, name: 'member declined email', path: 'group_mailer/member_declined', subject: 'Your membership request on {{ group.name }} has been declined', alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_member_has_quit_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberHasQuit, name: 'member has quitted email', path: 'group_mailer/member_has_quit', subject: '{{owner.first_name}}, {{ user.first_name }} decided to be no longer member on {{ group.name }}', alert_type: 'email', recipient_type: 'lister'})
  end

  protected

  def workflow_type
    'group_workflow'
  end

end
