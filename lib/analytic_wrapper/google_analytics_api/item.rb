# Class that represents Item that will be tracked in Google Analytics. 
# Item belongs to Transaction in Google Analytics [ transaction has many items ]
#
# see https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#ecom
class AnalyticWrapper::GoogleAnalyticsApi::Item
  include AnalyticWrapper::GoogleAnalyticsApi::Trackable

  def initialize(serialized_objects)
    @transaction_id = serialized_objects[:reservation_charge_id]
    @item_name = serialized_objects[:listing_name]
    @revenue = serialized_objects[:amount]
    @category = serialized_objects[:instance_name]
  end

  def customized_params
    {
      t: 'item',
      ti: @transaction_id,
      in: @item_name,
      ip: @revenue,
      iq: 1,
      iv: @category,
      cu: "USD"
    }
  end

end
