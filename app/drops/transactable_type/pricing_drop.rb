# frozen_string_literal: true
class TransactableType::PricingDrop < BaseDrop
  # @return [TransactableType::PricingDrop]

  # @!method id
  #   @return [Integer] numeric identifier for this pricing object
  # @!method action
  #   @return [TransactableType::ActionTypeDrop] action type to which this pricing belongs
  #     e.g. offer, subscription, time based booking, event based booking etc.
  # @!method unit
  #   @return [String] unit used for this pricing (e.g. night, day, hour, day_month, night_month,
  #     subscription_day, subscription_month, event etc.)
  # @!method min_price
  #   @return [MoneyDrop] Minimum price for this pricing
  # @!method max_price
  #   @return [MoneyDrop] Maximum price for this pricing
  # @!method fixed_price
  #   @return [MoneyDrop] Fixed price for this pricing
  # @!method fixed_price_cents
  #   @return [Integer] Fixed price in cents for this pricing
  # @!method number_of_units
  #   @return [Integer] number of the specified units for this pricing object
  delegate :id, :action, :unit, :number_of_units, :min_price, :max_price,
    :fixed_price, :fixed_price_cents, to: :source

end
