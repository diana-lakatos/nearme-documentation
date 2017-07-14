# frozen_string_literal: true
class ScheduleSitemapsRefresh
  include Delayed::RecurringJob
  run_every 1.day
  run_at '4:00am'
  timezone 'UTC'
  queue 'recurring-jobs'

  def perform
    Instance.find_each do |i|
      pc = i.set_context!
      SitemapsRefreshJob.perform(pc.domain.id)
    end
  end
end
