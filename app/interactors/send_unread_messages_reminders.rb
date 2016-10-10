class SendUnreadMessagesReminders
  include Delayed::RecurringJob
  run_every 1.day
  run_at '0:30am'
  timezone 'UTC'
  queue 'recurring-jobs'
  def perform
    UnreadMessagesRemindersJob.perform
  end
end
