require 'rest-client'

class GoogleAnalyticsApiJob < Job
  def after_initialize(endpoint, params)
    @endpoint = endpoint
    @params = params
  end

  def perform
    # documentation says that the request should be post, but actually must be get. not a mistake - tested!
    RestClient.get(@endpoint, params: @params, timeout: 4, open_timeout: 4) if DesksnearMe::Application.config.perform_google_analytics_requests
  end
end
