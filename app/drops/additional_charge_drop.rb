class AdditionalChargeDrop < BaseDrop
  # @return [AdditionalCharge]
  attr_reader :additional_charge

  # @!method name
  #   name of additional charge
  #   @return (see AdditionalCharge#name)
  # @!method amount
  #   amount of additional charge
  #   @return [Money]
  # @!method additional_charge_type_id
  #   additional_charge_type_id
  #   @return [Integer]
  # @!method amount_with_currency
  #   @return (see AdditionalChargeDecorator#amount_with_currency)
  delegate :name, :amount, :additional_charge_type_id, :amount_with_currency, to: :additional_charge

  def initialize(additional_charge)
    @additional_charge = additional_charge.decorate
  end

  # @return [String] the formatted amount depending on global settings for currency formatting
  def formatted_amount
    render_money(amount)
  end
end
