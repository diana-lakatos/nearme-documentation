class ShipmentDrop < BaseDrop

  attr_reader :shipment

  delegate :tracking_url_provider, :tracking_number, :label_url, :direction, :shipping_rule, to: :shipment

  def initialize(shipment)
    @shipment = shipment
  end

end
