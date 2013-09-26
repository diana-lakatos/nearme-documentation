class GoogleAnalyticsApiJob < Job
  def initialize(parameters)
    @parameters = parameters
  end

  def perform
    # documentation says that the request should be post, but actually must be get. not a mistake - tested!
    RestClient.get("http://www.google-analytics.com/collect", params: @parameters, timeout: 4, open_timeout: 4)
  end

end
