class Transactable::PricingDrop < BaseDrop

  attr_reader :pricing

  delegate :id, :action, to: :pricing

  def initialize(pricing)
    @pricing = pricing
  end

end
