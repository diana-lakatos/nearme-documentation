class GoogleAnalyticsApiJob < Job
  def initialize(object)
    @object = object
  end

  def perform
    # documentation says that the request should be post, but actually must be get. not a mistake - tested!
    RestClient.get(@object.class::ENDPOINT, params: @object.params, timeout: 4, open_timeout: 4) if DesksnearMe::Application.config.perform_google_analytics_requests
  end

end
