class Order::Recurring < Order
  def cancel
    update_attribute :end_on, paid_until
    if cancelled_by_guest?
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::EnquirerCancelled, id)
    elsif cancelled_by_host?
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::ListerCancelled, id)
    end
  end

  def generate_next_period!
    RecurringBooking.transaction do
      # Most likely next_charge_date would be Date.current, however
      # we do not want to rely on delayed_job being invoked on proper day.
      # If we invoke this job later than we should, we don't want to corrupt dates,
      # this is much more safer
      period_start_date = next_charge_date

      recalculate_next_charge_date!
      recurring_booking_periods.create!(
        service_fee_amount_guest_cents: amount_calculator.guest_service_fee.cents,
        service_fee_amount_host_cents: amount_calculator.host_service_fee.cents,
        subtotal_amount_cents: amount_calculator.subtotal_amount.cents,
        period_start_date: period_start_date,
        period_end_date: next_charge_date - 1.day,
        credit_card_id: credit_card_id,
        currency: currency
      ).tap do
        # to avoid cache issues if one would like to generate multiple periods in the future
        self.amount_calculator = nil
      end
    end
  end
end
