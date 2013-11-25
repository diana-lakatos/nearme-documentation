# Class that represents Event that will be tracked in Google Analytics

# see https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide
class AnalyticWrapper::GoogleAnalyticsApi::Event
  include AnalyticWrapper::GoogleAnalyticsApi::Trackable

  def initialize(category, action)
    @category = category
    @action = action
  end

  def customized_params
    {
      t: "event",
      ec: @category,
      ea: @action
    }
  end

end
