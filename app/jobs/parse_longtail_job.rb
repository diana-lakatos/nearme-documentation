# frozen_string_literal: true
class ParseLongtailJob < Job
  include Job::LongRunning
  def after_initialize(longtail_integration_id)
    @longtail_integration_id = longtail_integration_id
  end

  def perform
    @longtail_integration = ThirdPartyIntegration::LongtailIntegration.find(@longtail_integration_id)
    @endpoint = LongtailApi::Endpoint.new(host: @longtail_integration.host,
                                          token: @longtail_integration.token)
    LongtailApi.new(endpoint: @endpoint, page_slug: @longtail_integration.page_slug, campaigns: @longtail_integration.campaigns).parse!
  end
end
