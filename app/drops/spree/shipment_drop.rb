class Spree::ShipmentDrop < BaseDrop

  attr_reader :shipment

  delegate :id, :order, :manifest, :tracking, to: :shipment

  def initialize(shipment)
    @shipment = shipment
  end

  def tracking_url
    if @shipment.shipping_method.present?
      @shipment.tracking_url
    else
      nil
    end
  end

end

