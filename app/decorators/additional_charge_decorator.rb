class AdditionalChargeDecorator < Draper::Decorator
  include CurrencyHelper

  delegate_all

  def amount_with_currency
    humanized_money_with_cents_and_symbol(amount || 0.to_money(currency))
  end

end