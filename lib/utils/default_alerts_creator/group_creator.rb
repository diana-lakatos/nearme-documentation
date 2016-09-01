class Utils::DefaultAlertsCreator::GroupCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    create_group_owner_added_collaborator_email!
    create_pending_approval_email!

    create_notify_user_approved_email!
    create_notify_members_of_new_member!

    create_member_declined_email!
    create_member_has_quit_email!

    create_member_accepts_invitation_email!
  end

  def create_group_owner_added_collaborator_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberAddedByGroupOwner, name: 'group_owner_added_member_email', path: 'group_mailer/group_owner_added_member_email', subject: "You're invited to join {{ group.name }}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_pending_approval_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberPendingApproval, name: 'notify group owner of pending request', path: 'group_mailer/pending_approval', subject: 'New request to join your {{ group.name }} group', alert_type: 'email', recipient_type: 'lister'})
  end

  def create_notify_user_approved_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberApproved, name: 'notify user of approved join request', path: 'group_mailer/notify_user_of_approved_join_request', subject: "You've been approved as a group member on {{ group.name }}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_notify_members_of_new_member!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberApproved, name: 'notify members of new member', path: 'group_mailer/notify_members_of_new_member', subject: "{{ user.first_name }} has been approved as a group member on {{ group.name }}", alert_type: 'email', recipient_type: 'enquirer', bcc_type: 'members'})
  end

  def create_member_accepts_invitation_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::UserAcceptsInvitation, name: 'user accepts invitation email', path: 'group_mailer/user_accepts_invitation', subject: "{{ user.first_name }} accepted invitation to group {{ group.name }}", alert_type: 'email', recipient_type: 'enquirer', bcc_type: 'members'})
  end

  def create_member_declined_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberDeclined, name: 'member declined email', path: 'group_mailer/member_declined', subject: 'Your membership request on {{ group.name }} has been declined', alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_member_has_quit_email!
    create_alert!({associated_class: WorkflowStep::GroupWorkflow::MemberHasQuit, name: 'member has quitted email', path: 'group_mailer/member_has_quit', subject: '{{ user.first_name }} decided to be no longer member of {{ group.name }}', alert_type: 'email', recipient_type: 'lister', bcc_type: 'members'})
  end

  protected

  def workflow_type
    'group_workflow'
  end

end
