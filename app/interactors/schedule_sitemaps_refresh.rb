class ScheduleSitemapsRefresh
  include Delayed::RecurringJob
  run_every 1.month
  run_at '3:00am'
  timezone 'UTC'
  queue 'recurring-jobs'

  def perform
    SitemapsRefreshJob.perform
  end
end

