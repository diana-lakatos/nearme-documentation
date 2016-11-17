# frozen_string_literal: true
# @todo Investigate for removal
class ShippingRuleDrop < BaseDrop
  # @return [ShippingRuleDrop]
  attr_reader :shipping_rule

  # @!method is_pickup
  #   Whether pickup is enabled for this rule
  #   @return (see ShippingRule#is_pickup)
  # @!method name
  #   Name for the shipping rule
  #   @return (see ShippingRule#name)
  # @!method price
  #   @return [MoneyDrop] price for the shipping rule
  # @!method is_worldwide
  #   Whether it specifies a domestic or worldwide rule
  #   @return (see ShippingRule#is_worldwide)
  # @!method use_shippo_for_price
  #   Whether the Shippo service is used for pricing
  #   @return (see ShippingRule#use_shippo_for_price)
  delegate :is_pickup, :name, :price, :is_worldwide, :use_shippo_for_price, to: :shipping_rule

  def initialize(shipping_rule)
    @shipping_rule = shipping_rule
  end
end
