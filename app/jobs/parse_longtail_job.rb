# frozen_string_literal: true
class ParseLongtailJob < Job
  include Job::LongRunning
  def after_initialize(longtail_integration_id)
    @longtail_integration_id = longtail_integration_id
  end

  def perform
    @longtail_integration = ThirdPartyIntegration::LongtailIntegration.find(@longtail_integration_id)
    LongtailApi.new(arguments).parse_keywords!
  end

  protected

  def arguments
    {
      token: @longtail_integration.token,
      host: @longtail_integration.host,
      page_slug: @longtail_integration.page_slug
    }
  end
end
