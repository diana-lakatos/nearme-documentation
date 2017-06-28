class ScheduleCommunityAggregatesCreation
  include Delayed::RecurringJob
  run_every 1.day
  run_at '1:00am'
  timezone 'UTC'
  queue 'recurring-jobs'
  def perform
    CommunityAggregatesCreationJob.perform
  end
end
