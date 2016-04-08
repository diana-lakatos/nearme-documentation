class AdditionalChargeDrop < BaseDrop
  attr_reader :additional_charge

  # name
  #   name of additional charge
  # amount
  #   amount of additional charge
  # additional_charge_type_id
  #   additional_charge_type_id
  # amount_with_currency
  #   returns amount with currency and cents
  delegate :name, :amount, :additional_charge_type_id, :amount_with_currency, to: :additional_charge

  def initialize(additional_charge)
    @additional_charge = additional_charge.decorate
  end

  def formatted_amount
    humanized_money_with_symbol(amount)
  end

end

