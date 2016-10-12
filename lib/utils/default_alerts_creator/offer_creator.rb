class Utils::DefaultAlertsCreator::OfferCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    notify_guest_of_expiration_email!
    notify_host_of_expiration_email!
    notify_guest_of_cancellation_by_guest_email!
    notify_guest_of_cancellation_by_host_email!
    notify_host_of_cancellation_by_host_email!
    notify_host_of_cancellation_by_guest_email!
    notify_host_offer_created_and_pending_confirmation_email!
    notify_host_offer_created_and_pending_confirmation_sms!
    notify_guest_offer_created_and_pending_confirmation_email!
    notify_guest_offer_confirmed_email!
    notify_guest_offer_confirmed_sms!
    notify_guest_offer_host_cancel_sms!
    notify_guest_offer_reject_sms!
    notify_host_offer_confirmed_email!
    notify_guest_offer_rejected_email!
    notify_host_offer_rejected_email!
    notify_guest_of_payment_request_email!
    request_rating_of_guest_from_host_email!
    request_rating_of_host_from_guest_email!
    create_notify_host_of_shipping_details_email!
    create_notify_guest_of_shipping_details_email!
    notify_host_of_approved_payment!
    notify_host_of_declined_payment!
    notify_guest_of_submitted_checkout!
    notify_guest_of_submitted_checkout_with_failed_authorization!
    notify_guest_of_penalty_charge_failed!
    notify_guest_of_penalty_charge_succeeded!
  end

  def notify_guest_of_expiration_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::Expired, name: 'notify_guest_of_expiration', path: 'offer_mailer/notify_guest_of_expiration', subject: "[{{platform_context.name}}] Your offer for '{{transactable.name}}' at {{offer.location.street}} has expired", alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_host_of_expiration_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::Expired, name: 'notify_host_of_expiration_email', path: 'offer_mailer/notify_host_of_expiration', subject: '[{{platform_context.name}}] An offer at one of your projects has expired', alert_type: 'email', recipient_type: 'lister')
  end

  def notify_guest_of_cancellation_by_guest_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::EnquirerCancelled, name: 'Notify guest of guest cancellation', path: 'offer_mailer/notify_guest_of_cancellation_by_guest', subject: '[{{platform_context.name}}] You just cancelled your offer', alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_host_of_cancellation_by_guest_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::EnquirerCancelled, name: 'Notify host of guest cancellation', path: 'offer_mailer/notify_host_of_cancellation_by_guest', subject: '[{{platform_context.name}}] {{enquirer.first_name }} cancelled their offer for {{ transactable.name }}', alert_type: 'email', recipient_type: 'lister')
  end

  def notify_guest_of_cancellation_by_host_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ListerCancelled, name: 'Notify guest of host cancellation', path: 'offer_mailer/notify_guest_of_cancellation_by_host', subject: '[{{platform_context.name}}] Your offer has been cancelled', alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_host_of_cancellation_by_host_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ListerCancelled, name: 'Notify host of host cancellation', path: 'offer_mailer/notify_host_of_cancellation_by_host', subject: '[{{platform_context.name}}] You just declined an offer', alert_type: 'email', recipient_type: 'lister')
  end

  def notify_host_offer_created_and_pending_confirmation_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::CreatedWithoutAutoConfirmation, name: 'Ask host for confirmation email', path: 'offer_mailer/notify_host_with_confirmation', subject: '[{{platform_context.name}}] {{enquirer.first_name}} has just submitted offer to your {{transactable.transactable_type.bookable_noun}}!', alert_type: 'email', recipient_type: 'lister')
  end

  def notify_host_offer_created_and_pending_confirmation_sms!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::CreatedWithoutAutoConfirmation, name: 'Ask host for confirmation sms', path: 'offer_sms_notifier/notify_host_with_confirmation', alert_type: 'sms', recipient_type: 'lister')
  end

  def notify_guest_offer_created_and_pending_confirmation_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::CreatedWithoutAutoConfirmation, name: 'Inform guest about pending confirmation', path: 'offer_mailer/notify_guest_with_confirmation', subject: '[{{platform_context.name}}] {{enquirer.first_name}}, your offer is pending confirmation', alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_guest_offer_confirmed_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ManuallyConfirmed, name: 'Notify guest of confirmation', path: 'offer_mailer/notify_guest_of_confirmation', alert_type: 'email', subject: '[{{platform_context.name}}] {{enquirer.first_name}}, your offer has been confirmed', recipient_type: 'enquirer')
  end

  def notify_host_offer_confirmed_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ManuallyConfirmed, name: 'notify_host_of_confirmation', path: 'offer_mailer/notify_host_of_confirmation', subject: '[{{platform_context.name}}] Thanks for confirming!', alert_type: 'email', recipient_type: 'lister')
  end

  def notify_guest_offer_confirmed_sms!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ManuallyConfirmed, name: 'notify_guest_of_confirmation_sms', path: 'offer_sms_notifier/notify_guest_with_state_change', alert_type: 'sms', recipient_type: 'enquirer')
  end

  def notify_guest_offer_host_cancel_sms!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ListerCancelled, name: 'notify_guest_of_confirmation_sms', path: 'offer_sms_notifier/notify_guest_with_state_change', alert_type: 'sms', recipient_type: 'enquirer')
  end

  def notify_guest_offer_reject_sms!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::Rejected, name: 'notify_guest_of_rejection_sms', path: 'offer_sms_notifier/notify_guest_with_state_change', alert_type: 'sms', recipient_type: 'enquirer')
  end

  def notify_guest_offer_rejected_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::Rejected, name: 'notify_guest_of_rejection', path: 'offer_mailer/notify_guest_of_rejection', subject: '[{{platform_context.name}}] Your offer has been rejected.', alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_guest_of_payment_request_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::PaymentRequest, name: 'notify_guest_of_payment_request_email', path: 'offer_mailer/notify_guest_of_payment_request', subject: "[{{platform_context.name}}] Your offer for '{{transactable.name}}' at {{offer.location.street}} requires payment", alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_host_offer_rejected_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::Rejected, name: 'notify_host_of_rejection', path: 'offer_mailer/notify_host_of_rejection', subject: "[{{platform_context.name}}] You have reject {{enquirer.first_name}}'s offer.", alert_type: 'email', recipient_type: 'lister')
  end

  def request_rating_of_guest_from_host_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::EnquirerRatingRequested, name: 'request_rating_of_guest_from_host', path: 'rating_mailer/request_rating_of_guest_from_host', subject: '[{{platform_context.name}}] How was your experience hosting {{@enquirer.first_name}}?', alert_type: 'email', recipient_type: 'lister')
  end

  def request_rating_of_host_from_guest_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ListerRatingRequested, name: 'request_rating_of_host_from_guest', path: 'rating_mailer/request_rating_of_host_from_guest', subject: "[{{platform_context.name}}] How was your experience at '{{transactable.name}}'?", alert_type: 'email', recipient_type: 'enquirer')
  end

  def create_notify_host_of_shipping_details_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ShippingDetails, name: 'notify_host_of_shipping_details', path: 'offer_mailer/notify_host_of_shipping_details', subject: '[{{platform_context.name}}] Here are your shipping details', alert_type: 'email', recipient_type: 'lister')
  end

  def create_notify_guest_of_shipping_details_email!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ShippingDetails, name: 'notify_guest_of_shipping_details', path: 'offer_mailer/notify_guest_of_shipping_details', subject: '[{{platform_context.name}}] Here are your shipping details', alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_host_of_approved_payment!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::EnquirerApprovedPayment, name: 'notify_host_of_approved_payment', path: 'offer_mailer/notify_host_of_approved_payment', subject: '[{{platform_context.name}}] {{enquirer.first_name}} confirmed payment!',  alert_type: 'email', recipient_type: 'lister')
  end

  def notify_host_of_approved_payment!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::EnquirerApprovedPayment, name: 'notify_host_of_approved_payment', path: 'offer_mailer/notify_host_of_approved_payment', subject: '[{{platform_context.name}}] {{enquirer.first_name}} confirmed payment!',  alert_type: 'email', recipient_type: 'lister')
  end

  def notify_host_of_declined_payment!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::EnquirerDeclinedPayment, name: 'notify_host_of_declined_payment', path: 'offer_mailer/notify_host_of_declined_payment', subject: '[{{platform_context.name}}] {{enquirer.first_name}} declined payment!',  alert_type: 'email', recipient_type: 'lister')
  end

  def notify_guest_of_submitted_checkout!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ListerSubmittedCheckout, name: 'notify_guest_of_submitted_checkout', path: 'offer_mailer/notify_guest_of_submitted_checkout', subject: '[{{platform_context.name}}] {{transactable.name}} submitted invoice',  alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_guest_of_submitted_checkout_with_failed_authorization!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::ListerSubmittedCheckoutButAuthorizationFailed, name: 'notify_guest_of_submitted_checkout_with_failed_authorization', path: 'offer_mailer/notify_guest_of_submitted_checkout_with_failed_authorization', subject: '[{{platform_context.name}}] {{transactable.name}} submitted invoice',  alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_guest_of_penalty_charge_failed!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::PenaltyChargeFailed, name: 'notify_guest_of_penalty_charge_failed', path: 'offer_mailer/notify_guest_of_penalty_charge_failed', subject: '[{{platform_context.name}}] Cancelation fee',  alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_guest_of_penalty_charge_succeeded!
    create_alert!(associated_class: WorkflowStep::OfferWorkflow::PenaltyChargeSucceeded, name: 'notify_guest_of_penalty_charge_succeeded', path: 'offer_mailer/notify_guest_of_penalty_charge_succeeded', subject: '[{{platform_context.name}}] Cancelation fee',  alert_type: 'email', recipient_type: 'enquirer')
  end

  protected

  def workflow_type
    'offer'
  end
end
