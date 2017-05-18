# frozen_string_literal: true
class RemoveOldMarketplaceReports
  include Delayed::RecurringJob
  run_every 1.week
  run_at 'monday 2:01am'
  timezone 'UTC'
  queue 'recurring-jobs'

  def perform
    Instance.find_each do |instance|
      instance.set_context!
      RemoveOldMarketplaceReportsJob.perform
    end
  end
end
