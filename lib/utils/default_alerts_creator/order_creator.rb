class Utils::DefaultAlertsCreator::OrderCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    create_confirm_email!
    create_cancel_email!
    create_notify_seller_email!
    create_notify_shipped_email!
    create_notify_approved_email!
    create_notify_buyer_of_shipping_info_email!
    create_notify_seller_of_shipping_info_email!
  end

  def create_confirm_email!
    create_alert!({associated_class: WorkflowStep::OrderWorkflow::Finalized, name: 'confirm_email_to_buyer', path: 'spree/order_mailer/confirm_email', subject: "{{'buy_sell_market.checkout.order_mailer.confirm_email.subject' | translate}}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_cancel_email!
    create_alert!({associated_class: WorkflowStep::OrderWorkflow::Cancelled, name: 'cancel_email_to_buyer', path: 'spree/order_mailer/cancel_email', subject: "{{'buy_sell_market.checkout.order_mailer.cancel_email.subject' | translate}}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_notify_seller_email!
    create_alert!({associated_class: WorkflowStep::OrderWorkflow::Finalized, name: 'confirm_email_to_seller', path: 'spree/order_mailer/notify_seller_email', subject: "{{'buy_sell_market.checkout.order_mailer.notify_seller_email.subject' | translate }}", alert_type: 'email', recipient_type: 'lister'})
  end

  def create_notify_shipped_email!
    create_alert!({associated_class: WorkflowStep::OrderWorkflow::Shipped, name: 'shipped_email_to_buyer', path: 'spree/shipment_mailer/shipped_email', subject: "{{'buy_sell_market.checkout.shipment_mailer.shipped_email.subject' | translate}} {{ order.number }}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_notify_approved_email!
    create_alert!({associated_class: WorkflowStep::OrderWorkflow::Approved, name: 'approved_email_to_buyer', path: 'spree/order_mailer/approved_email', subject: "{{'buy_sell_market.checkout.order_mailer.approved_email.subject' | translate}} {{ order.number }}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_notify_buyer_of_shipping_info_email!
    create_alert!({associated_class: WorkflowStep::OrderWorkflow::ShippingInfo, name: 'shipping_info_for_buyer', path: 'spree/order_mailer/shipping_info_for_buyer', subject: "{{'buy_sell_market.checkout.order_mailer.shipping_info_for_buyer_email.subject' | translate}}", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_notify_seller_of_shipping_info_email!
    create_alert!({associated_class: WorkflowStep::OrderWorkflow::ShippingInfo, name: 'shipping_info_for_seller', path: 'spree/order_mailer/shipping_info_for_seller', subject: "{{'buy_sell_market.checkout.order_mailer.shipping_info_for_seller_email.subject' | translate}}", alert_type: 'email', recipient_type: 'lister'})
  end

  protected

  def workflow_type
    'order'
  end

end

