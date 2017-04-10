# frozen_string_literal: true
class Transactable::ActionTypeDrop < BaseDrop
  include AvailabilityRulesHelper
  # @return [Transactable::ActionTypeDrop]
  attr_reader :action_type

  # @!method id
  #   @return [Integer] numeric identifier for the transactable action type
  # @!method pricings
  #   @return [Array<Transactable::PricingDrop>] array of pricings
  # @!method transactable_type_action_type
  #   @return [TransactableType::ActionTypeDrop] array of transactable_type_action_type
  delegate :id, :pricings, :transactable_type_action_type, to: :action_type

  def initialize(action_type)
    @action_type = action_type
  end

  # @return [Transactable::PricingDrop] returns the first pricing
  # @todo - remove, DIY
  def first_pricing
    @action_type.pricings.first
  end

  # @return [Array<Transactable::PricingDrop>] sorted (by number of units) pricing objects for this action type
  # @todo - move sorting to filter
  def sorted_pricings
    @action_type.pricings.sort_by(&:number_of_units)
  end

  # @return [Hash{String => MoneyDrop}] hash of the form !{ 'pricing_unit' => MoneyDrop } for example
  #   { 'day' => MoneyDrop }
  def pricings_hash
    @pricings_hash ||= @action_type.pricings.each_with_object({}) { |pricing, hash| hash[pricing.unit] = pricing.price }
  end

  # @return [Array<Hash>] array containing all available templates that can be used for transacable
  def availability_templates_choices
    availability_choices(@action_type)
  end
end
