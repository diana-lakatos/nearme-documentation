class SendActivityEventsSummary
  include Delayed::RecurringJob
  run_every 1.week
  run_at 'monday 0:01am'
  timezone 'UTC'
  queue 'recurring-jobs'

  def perform
    SendActivityEventsSummaryJob.perform
  end
end
