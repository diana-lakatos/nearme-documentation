class SendAnalyticsMails
  include Delayed::RecurringJob
  run_every 1.month
  run_at '1 0:01am'
  timezone 'UTC'
  queue 'recurring-jobs'
  def perform
    RecurringMailerAnalyticsJob.perform
  end
end
