# frozen_string_literal: true
class Transactable::ActionTypeDrop < BaseDrop
  # @return [Transactable::ActionTypeDrop]
  attr_reader :action_type

  # @!method id
  #   @return [Integer] numeric identifier for the transactable action type
  # @!method pricings
  #   @return [Array<Transactable::PricingDrop>] array of pricings
  delegate :id, :pricings, to: :action_type

  def initialize(action_type)
    @action_type = action_type
  end

  # @return [Transactable::PricingDrop] returns the first pricing
  # @todo - remove, DIY
  def first_pricing
    pricings.first
  end

  # @return [Array<Transactable::PricingDrop>] sorted (by number of units) pricing objects for this action type
  # @todo - move sorting to filter
  def sorted_pricings
    pricings.sort_by(&:number_of_units)
  end

  # @return [Hash{String => MoneyDrop}] hash of the form !{ 'pricing_unit' => MoneyDrop } for example
  #   { 'day' => MoneyDrop }
  def pricings_hash
    @pricings_hash ||= pricings.each_with_object({}) { |pricing, hash| hash[pricing.unit] = pricing.price }
  end
end
