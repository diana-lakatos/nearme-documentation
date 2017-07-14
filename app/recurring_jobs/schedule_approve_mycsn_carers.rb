# frozen_string_literal: true
class ScheduleApproveMycsnCarers
  include Delayed::RecurringJob
  run_every 1.day
  run_at '10:59pm'
  timezone 'Sydney'
  queue 'recurring-jobs'
  def perform
    instance = Instance.find_by(id: Instances::InstanceFinder::INSTANCE_IDS[:mycsn])
    return if instance.nil?
    instance.set_context!
    ApproveMycsnCarersJob.perform
  end
end
