class ShipmentDrop < BaseDrop
  
  # @return [Shipment]
  attr_reader :shipment

  # @!method tracking_url_provider
  #   URL for tracking the shipment
  #   @return (see Shipment#tracking_url_provider)
  # @!method tracking_number
  #   Tracking number for the shipment
  #   @return (see Shipment#tracking_number)
  # @!method label_url
  #   URL to the package label
  #   @return (see Shipment#label_url)
  # @!method direction
  #   Shipment direction (inbound / outbound)
  #   @return (see Shipment#direction)
  # @!method shipping_rule
  #   ShippingRule object associated with the shipment
  #   @return (see Shipment#shipping_rule)
  delegate :tracking_url_provider, :tracking_number, :label_url, :direction, :shipping_rule, to: :shipment

  def initialize(shipment)
    @shipment = shipment
  end
end
