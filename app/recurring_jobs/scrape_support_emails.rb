class ScrapeSupportEmails
  include Delayed::RecurringJob
  run_every 10.minutes
  timezone 'UTC'
  queue 'recurring-jobs'
  def perform
    ReceiveMailsSpawnerJob.perform
  end
end
