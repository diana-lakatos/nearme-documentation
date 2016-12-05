# frozen_string_literal: true
class ShippingProfileDrop < BaseDrop
  # @return [ShippingProfileDrop]
  attr_reader :shipping_profile

  # @!method name
  #   @return [String] Name for the shipping profile (e.g. user name)
  # @!method shipping_rules
  #   @return [Array<ShippingRuleDrop>] Shipping rules associated with this profile
  delegate :name, :shipping_rules, to: :shipping_profile

  def initialize(shipping_profile)
    @shipping_profile = shipping_profile
  end
end
