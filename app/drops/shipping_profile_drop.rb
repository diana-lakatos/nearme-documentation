class ShippingProfileDrop < BaseDrop

  # @return [ShippingProfile]
  attr_reader :shipping_profile

  # @!method name
  #   Name for the shipping profile (e.g. user name)
  #   @return (see ShippingProfile#name)
  # @!method shipping_rules
  #   Shipping rules associated with this profile
  #   @return (see ShippingProfile#shipping_rules)
  delegate :name, :shipping_rules, to: :shipping_profile

  def initialize(shipping_profile)
    @shipping_profile = shipping_profile
  end

end
