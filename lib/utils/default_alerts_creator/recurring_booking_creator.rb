class Utils::DefaultAlertsCreator::RecurringBookingCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    notify_guest_of_expiration_email!
    notify_host_of_expiration_email!
    notify_guest_of_cancellation_by_guest_email!
    notify_guest_of_cancellation_by_host_email!
    notify_host_of_cancellation_by_host_email!
    notify_host_of_cancellation_by_guest_email!
    notify_guest_recurring_booking_created_and_confirmed_email!
    notify_host_recurring_booking_created_and_confirmed_email!
    notify_host_recurring_booking_created_and_pending_confirmation_email!
    notify_host_recurring_booking_created_and_pending_confirmation_sms!
    notify_guest_recurring_booking_created_and_pending_confirmation_email!
    notify_guest_recurring_booking_confirmed_email!
    notify_guest_recurring_booking_confirmed_sms!
    notify_host_recurring_booking_confirmed_email!
    notify_guest_recurring_booking_rejected_email!
    notify_host_recurring_booking_rejected_email!
    notify_host_recurring_booking_payment_overdue_email!
    notify_guest_recurring_booking_payment_overdue_email!
    notify_host_recurring_booking_payment_information_updated_email!
  end

  def notify_guest_of_expiration_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::Expired, name: 'notify_guest_of_expiration', path: 'recurring_booking_mailer/notify_guest_of_expiration', subject: "[{{platform_context.name}}] Your recurring booking for '{{recurring_booking.transactable.name}}' at {{recurring_booking.location.street}} has expired", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_of_expiration_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::Expired, name: 'notify_host_of_expiration_email', path: 'recurring_booking_mailer/notify_host_of_expiration', subject: "[{{platform_context.name}}] A recurring booking at one of your listings has expired", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_of_cancellation_by_guest_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::EnquirerCancelled, name: 'Notify guest of guest cancellation', path: 'recurring_booking_mailer/notify_guest_of_cancellation_by_guest', subject: "[{{platform_context.name}}] You just cancelled a recurring booking", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_of_cancellation_by_guest_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::EnquirerCancelled, name: 'Notify host of guest cancellation', path: 'recurring_booking_mailer/notify_host_of_cancellation_by_guest', subject: "[{{platform_context.name}}] {{recurring_booking.owner.first_name }} cancelled a recurring booking for '{{recurring_booking.transactable.name}}' at {{recurring_booking.location.street}}", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_of_cancellation_by_host_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::ListerCancelled, name: 'Notify guest of host cancellation', path: 'recurring_booking_mailer/notify_guest_of_cancellation_by_host', subject: "[{{platform_context.name}}] Your recurring booking for '{{recurring_booking.transactable.name}}' at {{recurring_booking.location.street}} was cancelled by the host", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_of_cancellation_by_host_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::ListerCancelled, name: 'Notify host of host cancellation', path: 'recurring_booking_mailer/notify_host_of_cancellation_by_host', subject: "[{{platform_context.name}}] You just declined a recurring booking", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_recurring_booking_created_and_confirmed_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::CreatedWithAutoConfirmation, name: 'Notify guest of confirmation', path: 'recurring_booking_mailer/notify_guest_of_confirmation', subject: "[{{platform_context.name}}] {{recurring_booking.owner.first_name}}, your recurring booking has been confirmed", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_recurring_booking_created_and_confirmed_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::CreatedWithAutoConfirmation, name: 'notify_host_without_confirmation', path: 'recurring_booking_mailer/notify_host_without_confirmation', subject: "[{{platform_context.name}}] {{recurring_booking.owner.first_name}} just booked your {{listing.transactable_type.bookable_noun}}!",  alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_host_recurring_booking_created_and_pending_confirmation_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation, name: 'Ask host for confirmation email', path: 'recurring_booking_mailer/notify_host_with_confirmation', subject: "[{{platform_context.name}}] {{recurring_booking.owner.first_name}} just booked your {{listing.transactable_type.bookable_noun}}!", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_host_recurring_booking_created_and_pending_confirmation_sms!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation, name: 'Ask host for confirmation sms', path: 'recurring_booking_sms_notifier/notify_host_with_confirmation', alert_type: 'sms', recipient_type: 'lister'})
  end

  def notify_guest_recurring_booking_created_and_pending_confirmation_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation, name: 'Inform guest about pending confirmation', path: 'recurring_booking_mailer/notify_guest_with_confirmation', subject: "[{{platform_context.name}}] {{recurring_booking.owner.first_name}}, your recurring booking is pending confirmation", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_guest_recurring_booking_confirmed_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::ManuallyConfirmed, name: 'Notify guest of confirmation', path: 'recurring_booking_mailer/notify_guest_of_confirmation', alert_type: 'email', subject: "[{{platform_context.name}}] {{recurring_booking.owner.first_name}}, your recurring booking has been confirmed", recipient_type: 'enquirer'})
  end

  def notify_host_recurring_booking_confirmed_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::ManuallyConfirmed, name: 'notify_host_of_confirmation', path: 'recurring_booking_mailer/notify_host_of_confirmation', subject: "[{{platform_context.name}}] Thanks for confirming!", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_recurring_booking_confirmed_sms!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::ManuallyConfirmed, name: 'notify_guest_of_status_change_sms', path: 'recurring_booking_sms_notifier/notify_guest_with_state_change', alert_type: 'sms', recipient_type: 'enquirer'})
  end

  def notify_guest_recurring_booking_rejected_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::Rejected, name: 'notify_guest_of_rejection', path: 'recurring_booking_mailer/notify_guest_of_rejection', subject: "[{{platform_context.name}}] Can we help, {{recurring_booking.owner.first_name}}?", alert_type: 'email', recipient_type: 'enquirer'})
  end

  def notify_host_recurring_booking_rejected_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::Rejected, name: 'notify_host_of_rejection', path: 'recurring_booking_mailer/notify_host_of_rejection', subject: "[{{platform_context.name}}] Can we help, {{user.first_name}}?", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_host_recurring_booking_payment_overdue_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::PaymentOverdue, name: 'notify_host_of_payment_overdue', path: 'recurring_booking_mailer/notify_host_of_payment_overdue', subject: "[{{platform_context.name}}] Payment overdue", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_host_recurring_booking_payment_information_updated_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::PaymentInformationUpdated, name: 'notify_host_of_payment_information_updated', path: 'recurring_booking_mailer/notify_host_of_payment_information_updated', subject: "[{{platform_context.name}}] {{ recurring_booking.owner.first_name }} updated payment information", alert_type: 'email', recipient_type: 'lister'})
  end

  def notify_guest_recurring_booking_payment_overdue_email!
    create_alert!({associated_class: WorkflowStep::RecurringBookingWorkflow::PaymentOverdue, name: 'notify_guest_of_payment_overdue', path: 'recurring_booking_mailer/notify_guest_of_payment_overdue', subject: "[{{platform_context.name}}] Payment overdue", alert_type: 'email', recipient_type: 'enquirer'})
  end

  protected

  def workflow_type
    'recurring_booking'
  end

end

