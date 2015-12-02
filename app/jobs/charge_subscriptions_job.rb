class ChargeSubscriptionsJob < Job

  def perform
    return true unless Rails.env.production?
    RecurringBooking.needs_charge(Date.current).find_each do |rb|
      ScheduleChargeSubscriptionJob.perform(rb.id)
    end
  end

end

