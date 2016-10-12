class ShippingRuleDrop < BaseDrop
  attr_reader :shipping_rule

  delegate :is_pickup, :name, :price, :is_worldwide, :use_shippo_for_price, to: :shipping_rule

  def initialize(shipping_rule)
    @shipping_rule = shipping_rule
  end
end
