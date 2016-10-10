# Class to extract params to track transaction in google analytics

# see https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide
class AnalyticWrapper::GoogleAnalyticsSerializer::Transaction
  def initialize(serialized_objects)
    @transaction_id = serialized_objects[:payment_id]
    @affiliation = serialized_objects[:instance_name]
    @revenue = serialized_objects[:amount]
  end

  def serialize
    {
      t: 'transaction',
      ti: @transaction_id,
      ta: @affiliation,
      tr: @revenue,
      cu: 'USD'
    }
  end
end
