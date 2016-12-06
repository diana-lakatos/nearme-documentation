# frozen_string_literal: true
class ShipmentDrop < BaseDrop
  # @return [ShipmentDrop]
  attr_reader :shipment

  # @!method tracking_url_provider
  #   @return [String] URL for tracking the shipment
  # @!method tracking_number
  #   @return [String] Tracking number for the shipment
  # @!method label_url
  #   @return [String] URL to the package label
  # @!method direction
  #   @return [String] Shipment direction (inbound / outbound)
  # @!method shipping_rule
  #   @return [ShippingRuleDrop] ShippingRule object associated with the shipment
  delegate :tracking_url_provider, :tracking_number, :label_url, :direction, :shipping_rule, to: :shipment

  def initialize(shipment)
    @shipment = shipment
  end
end
