# Class to extract params to track Event in google analytics

# see https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide
class AnalyticWrapper::GoogleAnalyticsSerializer::Event

  def initialize(category, action)
    @category = category
    @action = action
  end

  def serialize
    {
      t: "event",
      ec: @category,
      ea: @action
    }
  end

end
