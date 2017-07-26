# frozen_string_literal: true
class ScheduleDevmeshExportData
  include Delayed::RecurringJob
  run_every 1.day
  run_at '3:00am'
  timezone 'Pacific Time (US & Canada)'
  queue 'recurring-jobs'
  def perform
    instance = Instance.find_by(id: Instances::InstanceFinder::INSTANCE_IDS[:devmesh])
    return if instance.nil?
    instance.set_context!
    ExportDevmeshDataJob.perform
  end
end
