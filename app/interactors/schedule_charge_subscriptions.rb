class ScheduleChargeSubscriptions
  include Delayed::RecurringJob
  run_every 1.day
  run_at '0:01am'
  timezone 'UTC'
  queue 'recurring-jobs'
  def perform
    ChargeSubscriptionsJob.perform if Rails.env.production?
  end
end
