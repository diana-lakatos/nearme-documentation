class PrepareFriendFinders
  include Delayed::RecurringJob
  run_every 1.week
  run_at 'friday 0:01am'
  timezone 'UTC'
  queue 'recurring-jobs'
  def perform
    PrepareFriendFindersJob.perform
  end
end
