# frozen_string_literal: true
# @todo Investigate for removal
class ShippingRuleDrop < BaseDrop
  # @return [ShippingRuleDrop]
  attr_reader :shipping_rule

  # @!method is_pickup
  #   @return [Boolean] Whether pickup is enabled for this rule
  # @!method name
  #   @return [String] Name for the shipping rule
  # @!method price
  #   @return [MoneyDrop] price for the shipping rule
  # @!method is_worldwide
  #   @return [Boolean] Whether it specifies a domestic or worldwide rule
  # @!method use_shippo_for_price
  #   @return [Boolean] Whether the Shippo service is used for pricing
  delegate :is_pickup, :name, :price, :is_worldwide, :use_shippo_for_price, to: :shipping_rule

  def initialize(shipping_rule)
    @shipping_rule = shipping_rule
  end
end
