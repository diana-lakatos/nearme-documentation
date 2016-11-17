# frozen_string_literal: true
class Transactable::ActionTypeDrop < BaseDrop
  # @return [Transactable::ActionTypeDrop]
  attr_reader :action_type

  # @!method id
  #   @return [Integer]
  # @!method pricings
  #   array of pricings
  #   @return (see Array<Transactable::PricingDrop>)
  delegate :id, :pricings, to: :action_type

  def initialize(action_type)
    @action_type = action_type
  end

  # @return [Transactable::PricingDrop] returns the first pricing
  def first_pricing
    pricings.first
  end

  # @return [Array<Transactable::PricingDrop>] sorted (by number of units) pricing objects for this action type
  def sorted_pricings
    pricings.sort_by(&:number_of_units)
  end

  # @return [Hash{String => MoneyDrop}] hash of the form !{ 'pricing_unit' => MoneyDrop } for example
  #   { 'day' => MoneyDrop }
  def pricings_hash
    @pricings_hash ||= pricings.each_with_object({}) { |pricing, hash| hash[pricing.unit] = pricing.price }
  end
end
