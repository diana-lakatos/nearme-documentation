# Class to extract params to track Item in google analytics

# see https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide
class AnalyticWrapper::GoogleAnalyticsSerializer::Item
  def initialize(serialized_objects)
    @transaction_id = serialized_objects[:payment_id]
    @item_name = serialized_objects[:listing_name]
    @revenue = serialized_objects[:amount]
    @category = serialized_objects[:instance_name]
  end

  def serialize
    {
      t: 'item',
      ti: @transaction_id,
      in: @item_name,
      ip: @revenue,
      iq: 1,
      iv: @category,
      cu: 'USD'
    }
  end
end
