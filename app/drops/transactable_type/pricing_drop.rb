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
  # @!method service_fee_guest_percent
  #   @return [Integer] Service fee paid by guest for this pricing
  # @!method service_fee_host_percent
  #   @return [Integer] Service fee paid by host for this pricing
  delegate :id, :action, :unit, :number_of_units, :min_price, :max_price,
           :fixed_price, :fixed_price_cents, :service_fee_guest_percent,
           :service_fee_host_percent, to: :source

  # @return [Float] Amount of Fixed price of pricing with Guest service fee
  def fixed_price_with_guest_service_fee
    @source.fixed_price.to_f + fixed_price_guest_service_fee
  end

  # @return [Float] Amount of Guest service fee for fixed pricing
  def fixed_price_guest_service_fee
    (@source.fixed_price * (@source.service_fee_guest_percent.to_f / 100)).to_f
  end

  # @return [Float] Amount of Fixed price of pricing with Host service fee
  def fixed_price_with_host_service_fee
    @source.fixed_price.to_f * (1 + @source.service_fee_host_percent.to_f / 100)
  end

  # @return [Float] Fixed price for this pricing
  def fixed_price_f
    @source.fixed_price.to_f
  end
end
