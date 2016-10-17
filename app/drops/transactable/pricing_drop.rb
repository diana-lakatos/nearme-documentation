class Transactable::PricingDrop < BaseDrop

  # @return [Transactable::Pricing]
  attr_reader :pricing

  # @!method id
  #   @return [Integer] numeric identifier for this pricing object
  # @!method action
  #   @return [Transactable::ActionType] action type to which this pricing belongs
  #     e.g. offer, subscription, time based booking, event based booking etc.
  delegate :id, :action, :unit, :price, :number_of_units, to: :pricing

  def initialize(pricing)
    @pricing = pricing
  end

end
