class Utils::DefaultAlertsCreator::ReservationCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    notify_guest_of_expiration_email!
    notify_host_of_expiration_email!
    notify_guest_of_cancellation_by_guest_email!
    notify_guest_of_cancellation_by_host_email!
    notify_host_of_cancellation_by_host_email!
    notify_host_of_cancellation_by_guest_email!
    notify_guest_reservation_created_and_confirmed_email!
    notify_host_reservation_created_and_confirmed_email!
    notify_host_reservation_created_and_pending_confirmation_email!
    notify_host_reservation_created_and_pending_confirmation_sms!
    notify_guest_reservation_created_and_pending_confirmation_email!
    notify_guest_reservation_confirmed_email!
    notify_guest_reservation_confirmed_sms!
    notify_guest_reservation_host_cancel_sms!
    notify_guest_reservation_reject_sms!
    notify_host_reservation_confirmed_email!
    notify_guest_reservation_rejected_email!
    notify_host_reservation_rejected_email!
    notify_guest_of_payment_request_email!
    notify_guest_pre_booking_email!
    notify_guest_one_booking_suggestions_email!
    request_rating_of_guest_from_host_email!
    request_rating_of_host_from_guest_email!
    create_notify_host_of_shipping_details_email!
    create_notify_guest_of_shipping_details_email!
    notify_host_of_approved_payment!
    notify_host_of_declined_payment!
    notify_guest_of_submitted_checkout!
    notify_guest_of_submitted_checkout_with_failed_authorization!
  end

  def notify_guest_of_expiration_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::Expired, name: 'notify_guest_of_expiration', path: 'reservation_mailer/notify_guest_of_expiration', subject: "[{{platform_context.name}}] Your booking for '{{reservation.listing.name}}' at {{reservation.location.street}} has expired", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_of_expiration_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::Expired, name: 'notify_host_of_expiration_email', path: 'reservation_mailer/notify_host_of_expiration', subject: "[{{platform_context.name}}] A booking at one of your listings has expired", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_of_cancellation_by_guest_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::GuestCancelled, name: 'Notify guest of guest cancellation', path: 'reservation_mailer/notify_guest_of_cancellation_by_guest', subject: "[{{platform_context.name}}] You just cancelled a booking", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_of_cancellation_by_guest_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::GuestCancelled, name: 'Notify host of guest cancellation', path: 'reservation_mailer/notify_host_of_cancellation_by_guest', subject: "[{{platform_context.name}}] {{reservation.owner.first_name }} cancelled a booking for '{{reservation.listing.name}}' at {{reservation.location.street}}", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_of_cancellation_by_host_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::HostCancelled, name: 'Notify guest of host cancellation', path: 'reservation_mailer/notify_guest_of_cancellation_by_host', subject: "[{{platform_context.name}}] Your booking for '{{reservation.listing.name}}' at {{reservation.location.street}} was cancelled by the host", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_of_cancellation_by_host_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::HostCancelled, name: 'Notify host of host cancellation', path: 'reservation_mailer/notify_host_of_cancellation_by_host', subject: "[{{platform_context.name}}] You just declined a booking", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_reservation_created_and_confirmed_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::CreatedWithAutoConfirmation, name: 'Notify guest of confirmation', path: 'reservation_mailer/notify_guest_of_confirmation', subject: "[{{platform_context.name}}] {{reservation.owner.first_name}}, your booking has been confirmed", alert_type: 'email', recipient_type: 'enquirer', custom_options: {'booking_calendar_attachment_name' => 'booking.ics'}})
  end

  def notify_host_reservation_created_and_confirmed_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::CreatedWithAutoConfirmation, name: 'notify_host_without_confirmation', path: 'reservation_mailer/notify_host_without_confirmation', subject: "[{{platform_context.name}}] {{reservation.owner.first_name}} just booked your {{listing.transactable_type.bookable_noun}}!",  alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_host_reservation_created_and_pending_confirmation_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, name: 'Ask host for confirmation email', path: 'reservation_mailer/notify_host_with_confirmation', subject: "[{{platform_context.name}}] {{reservation.owner.first_name}} just booked your {{listing.transactable_type.bookable_noun}}!", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_host_reservation_created_and_pending_confirmation_sms!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, name: 'Ask host for confirmation sms', path: 'reservation_sms_notifier/notify_host_with_confirmation', alert_type: 'sms', recipient_type: 'lister'})
  end

  def notify_guest_reservation_created_and_pending_confirmation_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation, name: 'Inform guest about pending confirmation', path: 'reservation_mailer/notify_guest_with_confirmation', subject: "[{{platform_context.name}}] {{reservation.owner.first_name}}, your booking is pending confirmation", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_guest_reservation_confirmed_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::ManuallyConfirmed, name: 'Notify guest of confirmation', path: 'reservation_mailer/notify_guest_of_confirmation', alert_type: 'email', subject: "[{{platform_context.name}}] {{reservation.owner.first_name}}, your booking has been confirmed", recipient_type: 'enquirer', custom_options: {'booking_calendar_attachment_name' => 'booking.ics'}})
  end

  def notify_host_reservation_confirmed_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::ManuallyConfirmed, name: 'notify_host_of_confirmation', path: 'reservation_mailer/notify_host_of_confirmation', subject: "[{{platform_context.name}}] Thanks for confirming!", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_reservation_confirmed_sms!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::ManuallyConfirmed, name: 'notify_guest_of_confirmation_sms', path: 'reservation_sms_notifier/notify_guest_with_state_change', alert_type: 'sms', recipient_type: 'enquirer'})
  end

  def notify_guest_reservation_host_cancel_sms!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::HostCancelled, name: 'notify_guest_of_confirmation_sms', path: 'reservation_sms_notifier/notify_guest_with_state_change', alert_type: 'sms', recipient_type: 'enquirer'})
  end

  def notify_guest_reservation_reject_sms!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::Rejected, name: 'notify_guest_of_confirmation_sms', path: 'reservation_sms_notifier/notify_guest_with_state_change', alert_type: 'sms', recipient_type: 'enquirer'})
  end
  def notify_guest_reservation_rejected_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::Rejected, name: 'notify_guest_of_rejection', path: 'reservation_mailer/notify_guest_of_rejection', subject: "[{{platform_context.name}}] Can we help, {{reservation.owner.first_name}}?", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_guest_of_payment_request_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::PaymentRequest, name: 'notify_guest_of_payment_request_email', path: 'reservation_mailer/notify_guest_of_payment_request', subject: "[{{platform_context.name}}] Your booking for '{{reservation.listing.name}}' at {{reservation.location.street}} requires payment", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_guest_pre_booking_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::OneDayToBooking, name: 'notify_guest_of_payment_request_email', path: 'reservation_mailer/pre_booking', subject: "[{{platform_context.name}}] {{reservation.owner.first_name}}, your booking is tomorrow!", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_reservation_rejected_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::Rejected, name: 'notify_host_of_rejection', path: 'reservation_mailer/notify_host_of_rejection', subject: "[{{platform_context.name}}] Can we help, {{user.first_name}}?", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_one_booking_suggestions_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::OneBookingSuggestions, name: 'send user with one reservation some suggestions', path: 'reengagement_mailer/one_booking', subject: "[{{platform_context.name}}] Check out these new {{listing.transactable_type.bookable_noun_plural}} in your area!", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def request_rating_of_guest_from_host_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::GuestRatingRequested, name: 'request_rating_of_guest_from_host', path: 'rating_mailer/request_rating_of_guest_from_host', subject: "[{{platform_context.name}}] How was your experience hosting {{@reservation.owner.first_name}}?", alert_type: 'email', recipient_type: 'lister'})
  end

  def request_rating_of_host_from_guest_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::HostRatingRequested, name: 'request_rating_of_host_from_guest', path: 'rating_mailer/request_rating_of_host_from_guest', subject: "[{{platform_context.name}}] How was your experience at '{{reservation.listing.name}}'?", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def create_notify_host_of_shipping_details_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::ShippingDetails, name: 'notify_host_of_shipping_details', path: 'reservation_mailer/notify_host_of_shipping_details', subject: "[{{platform_context.name}}] Here are your shipping details", alert_type: 'email', recipient_type: 'lister'})
  end

  def create_notify_guest_of_shipping_details_email!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::ShippingDetails, name: 'notify_guest_of_shipping_details', path: 'reservation_mailer/notify_guest_of_shipping_details', subject: "[{{platform_context.name}}] Here are your shipping details", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_of_approved_payment!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::GuestApprovedPayment, name: 'notify_host_of_approved_payment', path: 'reservation_mailer/notify_host_of_approved_payment', subject: "[{{platform_context.name}}] {{reservation.owner.first_name}} confirmed payment!",  alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_host_of_approved_payment!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::GuestApprovedPayment, name: 'notify_host_of_approved_payment', path: 'reservation_mailer/notify_host_of_approved_payment', subject: "[{{platform_context.name}}] {{reservation.owner.first_name}} confirmed payment!",  alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_host_of_declined_payment!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::GuestDeclinedPayment, name: 'notify_host_of_declined_payment', path: 'reservation_mailer/notify_host_of_declined_payment', subject: "[{{platform_context.name}}] {{reservation.owner.first_name}} declined payment!",  alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_of_submitted_checkout!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::HostSubmittedCheckout, name: 'notify_guest_of_submitted_checkout', path: 'reservation_mailer/notify_guest_of_submitted_checkout', subject: "[{{platform_context.name}}] {{reservation.listing.name}} submitted invoice",  alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_guest_of_submitted_checkout_with_failed_authorization!
    create_alert!({associated_class: WorkflowStep::ReservationWorkflow::HostSubmittedCheckoutButAuthorizationFailed, name: 'notify_guest_of_submitted_checkout_with_failed_authorization', path: 'reservation_mailer/notify_guest_of_submitted_checkout_with_failed_authorization', subject: "[{{platform_context.name}}] {{reservation.listing.name}} submitted invoice",  alert_type: 'email', recipient_type: 'enquirer'})
  end

  protected

  def workflow_type
    'reservation'
  end

end

