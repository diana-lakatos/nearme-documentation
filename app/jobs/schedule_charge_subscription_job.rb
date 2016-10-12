class ScheduleChargeSubscriptionJob < Job
  def after_initialize(recurring_booking_id)
    @recurring_booking_id = recurring_booking_id
  end

  def perform
    recurring_booking = RecurringBooking.find(@recurring_booking_id)
    recurring_booking.instance.set_context!
    # if something goes wrong with delayed job, we don't want to use Date.current - instead, we
    # want to set proper date.

    # If for some reason we missed period or more, we want to fix the db state. So we loop
    # until next charge date is in the future.
    #
    # This should also prevent us from creating new periods during re-trying the job, if for example payment failed.

    current_charge_date = recurring_booking.next_charge_date
    until recurring_booking.next_charge_date > Time.zone.now
      period = recurring_booking.generate_next_period!
      period.generate_payment!
      fail 'Invalid state, next charge date has not moved forward! Infinite loop would occur.' if recurring_booking.next_charge_date.nil? || (recurring_booking.next_charge_date <= current_charge_date)
    end
  end
end
