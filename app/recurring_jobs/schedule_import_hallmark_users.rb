# frozen_string_literal: true
class ScheduleImportHallmarkUsers
  include Delayed::RecurringJob
  run_every 1.day
  run_at '10:59pm'
  timezone 'Pacific Time (US & Canada)'
  queue 'recurring-jobs'
  def perform
    instance = Instance.find_by(id: Instances::InstanceFinder::INSTANCE_IDS[:hallmark])
    return if instance.nil?
    instance.set_context!
    ImportHallmarkUsersJob.perform
  end
end
