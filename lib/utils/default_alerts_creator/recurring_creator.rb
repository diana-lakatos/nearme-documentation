class Utils::DefaultAlertsCreator::RecurringCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    create_analytics_email!
    create_share_email!
    create_request_photos_email!
  end

  def create_analytics_email!
    create_alert!({associated_class: WorkflowStep::RecurringWorkflow::Analytics, name: 'analytics email', path: 'recurring_mailer/analytics', subject: "{{company.creator.first_name}}, we have potential guests for you!", alert_type: 'email', recipient_type: 'lister'})
  end

  def create_share_email!
    create_alert!({associated_class: WorkflowStep::RecurringWorkflow::Share, name: 'share email', path: 'recurring_mailer/share', subject: "Share your listing '{{listing.name}}' at {{listing.location.street}} and increase bookings!", alert_type: 'email', recipient_type: 'lister'})
  end

  def create_request_photos_email!
    create_alert!({associated_class: WorkflowStep::RecurringWorkflow::RequestPhotos, name: 'request photos email', path: 'recurring_mailer/request_photos', subject: "Give the final touch to your listings with some photos!", alert_type: 'email', recipient_type: 'lister'})
  end

  protected

  def workflow_type
    'recurring'
  end

end
