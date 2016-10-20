class Transactable::PricingDrop < BaseDrop
  attr_reader :pricing

  delegate :id, :action, :unit, :price, :number_of_units, to: :pricing

  def initialize(pricing)
    @pricing = pricing
  end
end
