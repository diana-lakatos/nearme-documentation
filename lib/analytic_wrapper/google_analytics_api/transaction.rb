# Class that represents Transaction that will be tracked in Google Analytics. 
#
# see https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#ecom
class AnalyticWrapper::GoogleAnalyticsApi::Transaction
  include AnalyticWrapper::GoogleAnalyticsApi::Trackable

  def initialize(serialized_objects)
    @transaction_id = serialized_objects[:reservation_charge_id]
    @affiliation = serialized_objects[:instance_name]
    @revenue = serialized_objects[:amount]
  end

  def customized_params
    {
      t: "transaction",
      ti: @transaction_id,
      ta: @affiliation,
      tr: @revenue,
      cu: 'USD'
    }
  end

end
