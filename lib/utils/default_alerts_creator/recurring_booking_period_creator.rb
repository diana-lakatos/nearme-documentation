class Utils::DefaultAlertsCreator::RecurringBookingPeriodCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    notify_guest_of_recurring_booking_period_paid!
    notify_host_of_recurring_booking_period_paid!
  end

  def notify_guest_of_recurring_booking_period_paid!
    create_alert!(associated_class: WorkflowStep::RecurringBookingPeriodWorkflow::Paid, name: 'notify_guest_of_recurring_booking_period_paid', path: 'recurring_booking_period_mailer/notify_guest_of_recurring_booking_period_paid', subject: "[{{platform_context.name}}] A payment was made for your recurring booking for '{{recurring_booking.transactable.name}}'", alert_type: 'email', recipient_type: 'enquirer')
  end

  def notify_host_of_recurring_booking_period_paid!
    create_alert!(associated_class: WorkflowStep::RecurringBookingPeriodWorkflow::Paid, name: 'notify_host_of_recurring_booking_period_paid', path: 'recurring_booking_period_mailer/notify_host_of_recurring_booking_period_paid', subject: "[{{platform_context.name}}] A payment was made for a recurring booking for your listing '{{recurring_booking.transactable.name}}'", alert_type: 'email', recipient_type: 'lister')
  end

  protected

  def workflow_type
    'recurring_booking_period'
  end
end
