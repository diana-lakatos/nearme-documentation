class Utils::DefaultAlertsCreator::InquiryCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    create_inquiry_created_host!
    create_inquiry_created_guest!
  end

  def create_inquiry_created_host!
    create_alert!({associated_class: WorkflowStep::InquiryWorkflow::Created, name: 'notify_host_on_inquiry_created', path: 'inquiry_mailer/listing_creator_notification', subject: "New enquiry from {{inquiry.inquiring_user.name}} about {{inquiry.listing.name}}", alert_type: 'email', recipient_type: 'lister'})
  end

  def create_inquiry_created_guest!
    create_alert!({associated_class: WorkflowStep::InquiryWorkflow::Created, name: 'notify_guest_on_inquiry_created', path: 'inquiry_mailer/inquiring_user_notification', subject: "We've passed on your inquiry about {{inquiry.listing.name}}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  protected

  def workflow_type
    'inquiry'
  end

end
