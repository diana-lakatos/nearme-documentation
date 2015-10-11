class ChargeSubscriptionsJob < Job

  def perform
    RecurringBooking.needs_charge(Date.current).find_each do |rb|
      ScheduleChargeSubscriptionJob.perform(rb.id)
    end
  end

end

