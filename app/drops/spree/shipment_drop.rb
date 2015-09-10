class Spree::ShipmentDrop < BaseDrop

  attr_reader :shipment

  # id
  #   numeric identifier for this shipment
  # order
  #   order to which this shipment belongs
  # manifest
  #   returns an array of ManifestItem objects with each object being a
  #   hash with key-value items. The relevant keys for a ManifestItem are: 
  #   line_item - the line_item to which the shipment refers, quantity - the 
  #   quantity shipped, variant - the product variant to which this shipment refers
  # tracking
  #   tracking information for this shipment
  # shippo_tracking_number
  #   tracking number from Shippo
  # shippo_label_url
  #   label URL from Shippo
  delegate :id, :order, :manifest, :tracking, :shippo_tracking_number, :shippo_label_url, to: :shipment

  def initialize(shipment)
    @shipment = shipment
  end

  # returns the tracking url for this shipment
  def tracking_url
    if @shipment.shipping_method.present?
      @shipment.tracking_url
    else
      nil
    end
  end

end

