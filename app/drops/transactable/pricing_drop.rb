# frozen_string_literal: true
class Transactable::PricingDrop < BaseDrop
  # @return [Transactable::PricingDrop]
  attr_reader :pricing

  # @!method id
  #   @return [Integer] numeric identifier for this pricing object
  # @!method action
  #   @return [Transactable::ActionTypeDrop] action type to which this pricing belongs
  #     e.g. offer, subscription, time based booking, event based booking etc.
  # @!method unit
  #   @return [String] unit used for this pricing (e.g. night, day, hour, day_month, night_month,
  #     subscription_day, subscription_month, event etc.)
  # @!method price
  #   @return [MoneyDrop] price set for this pricing object
  # @!method number_of_units
  #   @return [Integer] number of the specified units for this pricing object
  delegate :id, :action, :unit, :price, :number_of_units, to: :pricing

  def initialize(pricing)
    @pricing = pricing
  end
end
