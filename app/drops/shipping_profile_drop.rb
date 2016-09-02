class ShippingProfileDrop < BaseDrop

  attr_reader :shipping_profile

  delegate :name, :shipping_rules, to: :shipping_profile

  def initialize(shipping_profile)
    @shipping_profile = shipping_profile
  end

end
