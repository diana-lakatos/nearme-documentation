class Utils::DefaultAlertsCreator::ListingCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_listing_created_email!
    create_draft_listing_created_email!
    share_with_user_email!
    create_listing_pending_approval_email!
    create_approved_email!
    create_rejected_email!
    create_questioned_email!
    create_inappropriated_email!
  end

  def create_listing_created_email!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::Created, name: 'listing_created_email', path: 'post_action_mailer/list', subject: '[{{platform_context.name}}] {{user.first_name}}, your new listing looks amazing!', alert_type: 'email', recipient_type: 'lister')
  end

  def create_draft_listing_created_email!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::DraftCreated, name: 'draft_listing_created_email', path: 'post_action_mailer/list_draft', subject: "[{{platform_context.name}}] {{user.first_name}}, you're almost ready for your first guests!", alert_type: 'email', recipient_type: 'lister', delay: 60)
  end

  def share_with_user_email!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::Shared, name: 'share with user email', path: 'listing_mailer/share', subject: '{{sharer.name}} has shared a {{listing.transactable_type.bookable_noun}} with you on {{platform_context.name}}', alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_listing_pending_approval_email!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::PendingApproval, name: 'listing_pending_approval_email', path: 'vendor_approval_mailer/notify_admin_of_new_listings', subject: 'New listing is pending approval', alert_type: 'email', recipient_type: 'Administrator', delay: 0)
  end

  def create_approved_email!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::Approved, name: 'listing_approved_email', path: 'vendor_approval_mailer/notify_host_of_listing_approval', subject: '{{ listing.name }} has been approved!', alert_type: 'email', recipient_type: 'lister', delay: 0)
  end

  def create_rejected_email!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::Rejected, name: 'listing_rejected_email', path: 'vendor_approval_mailer/notify_host_of_listing_rejection', subject: '{{ listing.name }} has been rejected!', alert_type: 'email', recipient_type: 'lister', delay: 0)
  end

  def create_questioned_email!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::Questioned, name: 'listing_questioned_email', path: 'vendor_approval_mailer/notify_host_of_listing_questioned', subject: '{{ listing.name }} is being reviewed!', alert_type: 'email', recipient_type: 'lister', delay: 0)
  end

  def create_inappropriated_email!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::InappropriateReported, name: 'listing_inappropriate_reported_email', path: 'inappropriate_reports_mailer/inappropriate_report', subject: '{{ listing.name }} has been flagged as inappropriate!', alert_type: 'email', recipient_type: 'Administrator', delay: 0)
  end

  def create_notify_lister_of_cancellation!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::Cancelled, name: 'notify_lister_of_cancellation', path: 'transactable_mailer/notify_lister_of_cancellation', subject: 'You have cancelled {{ listing.name }}!', alert_type: 'email', recipient_type: 'lister', delay: 0)
  end

  def create_notify_collaborators_of_cancellation!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::Cancelled, name: 'notify_collaborators_of_cancellation', path: 'transactable_mailer/notify_collaborators_of_cancellation', subject: '{{ listing.name }} has been cancelled!', alert_type: 'email', recipient_type: '', bcc_type: 'collaborators', delay: 0)
  end

  def create_notify_lister_of_completion!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::Cancelled, name: 'notify_lister_of_completion', path: 'transactable_mailer/notify_lister_of_completion', subject: 'You have marked {{ listing.name }} as completed!', alert_type: 'email', recipient_type: 'lister', delay: 0)
  end

  def create_notify_enquirer_of_completion!
    create_alert!(associated_class: WorkflowStep::ListingWorkflow::Completed, name: 'notify_enquirer_of_completion', path: 'transactable_mailer/notify_enquirer_of_completion', subject: '{{ listing.name }} has been marked as completed!', alert_type: 'email', recipient_type: 'enquirer', delay: 0)
  end

  protected

  def workflow_type
    'listing'
  end
end
