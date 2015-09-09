class SendRatingReminders
  include Delayed::RecurringJob
  run_every 1.hour
  timezone 'UTC'
  queue 'recurring-jobs'
  def perform
    RatingReminderJob.perform(Time.zone.today.to_s)
  end
end
