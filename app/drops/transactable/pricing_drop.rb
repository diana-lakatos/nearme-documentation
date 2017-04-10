# frozen_string_literal: true
class Transactable::PricingDrop < BaseDrop
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
  # @!method service_fee_guest_percent
  #   @return [Integer] Service fee paid by guest for this pricing
  # @!method service_fee_host_percent
  #   @return [Integer] Service fee paid by host for this pricing
  delegate :id, :action, :unit, :price, :number_of_units, :service_fee_host_percent,
           :service_fee_guest_percent, to: :source
end
