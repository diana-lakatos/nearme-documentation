# frozen_string_literal: true
class ShippingProfileDrop < BaseDrop
  # @return [ShippingProfileDrop]
  attr_reader :shipping_profile

  # @!method name
  #   Name for the shipping profile (e.g. user name)
  #   @return (see ShippingProfile#name)
  # @!method shipping_rules
  #   @return [Array<ShippingRuleDrop>] Shipping rules associated with this profile
  delegate :name, :shipping_rules, to: :shipping_profile

  def initialize(shipping_profile)
    @shipping_profile = shipping_profile
  end
end
