class AdditionalChargeDecorator < Draper::Decorator
  include CurrencyHelper

  delegate_all

  # @return [String] amount with currency and cents (depending on global settings)
  def amount_with_currency
    render_money(amount || 0.to_money(currency))
  end
end
