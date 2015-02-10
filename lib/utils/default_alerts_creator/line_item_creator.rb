class Utils::DefaultAlertsCreator::LineItemCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    request_rating_of_host_and_product_from_guest_email!
    request_rating_of_guest_from_host_email!
  end

  def request_rating_of_host_and_product_from_guest_email!
    create_alert!({
      associated_class: WorkflowStep::LineItemWorkflow::HostAndProductRatingRequested, 
      name: 'request_rating_of_host_and_product_from_guest_email', 
      path: 'rating_mailer/line_items/request_rating_of_host_and_product_from_guest', 
      subject: "[{{platform_context.name}}] How was your order of '{{line_item.product_name}}'?", 
      alert_type: 'email', 
      recipient_type: 'enquirer'
    })
  end

  def request_rating_of_guest_from_host_email!
    create_alert!({
      associated_class: WorkflowStep::LineItemWorkflow::GuestRatingRequested, 
      name: 'request_rating_of_guest_from_host_email', 
      path: 'rating_mailer/line_items/request_rating_of_host_and_product_from_guest', 
      subject: "[{{platform_context.name}}] How was your buyer of '{{line_item.product_name}}'?", 
      alert_type: 'email', 
      recipient_type: 'lister'
    })
  end

  protected

  def workflow_type
    'line_item'
  end
end