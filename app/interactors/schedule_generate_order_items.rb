class ScheduleGenerateOrderItems
  include Delayed::RecurringJob
  run_every 1.hour
  queue 'recurring-jobs'

  def perform
    GenerateOrderItemsJob.perform if Rails.env.production?
  end
end
