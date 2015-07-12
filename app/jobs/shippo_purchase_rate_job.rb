# Purchase shippo rate
class ShippoPurchaseRateJob < Job

  def after_initialize(shipping_method)
    @shipping_method = shipping_method
  end

  def perform
    purchase_result = ShippoExtensions::SpreeExtensions.purchase_shippo_quoted_shipping_rate(@shipping_method.shippo_rate_id)

    if purchase_result.present?
      @shipping_method.order.update_column(:shippo_rate_purchased_at, Time.now)
      @shipping_method.update_column(:shippo_label_url, purchase_result.label_url)
      @shipping_method.update_column(:shippo_tracking_number, purchase_result.tracking_number)
    else
      # This is supposed to make delayed job retry the job
      raise ShippoExtensions::ShippoApiMethodCallingError.new 'Error purchasing rate from Shippo.'
    end
  end

end
