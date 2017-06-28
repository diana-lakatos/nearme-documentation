# frozen_string_literal: true
class ScheduleLongtailApiParse
  include Delayed::RecurringJob
  run_every 1.day
  run_at '0:01am'
  timezone 'UTC'
  queue 'recurring-jobs'
  def perform
    ThirdPartyIntegration::LongtailIntegration.unscoped.where(environment: Rails.env).find_each do |longtail_integration|
      longtail_integration.instance.set_context!
      ParseLongtailJob.perform(longtail_integration.id)
      PlatformContext.current = nil
    end
  end
end
