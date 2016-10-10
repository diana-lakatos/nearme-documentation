class AdditionalChargeDecorator < Draper::Decorator
  include CurrencyHelper

  delegate_all

  def amount_with_currency
    render_money(amount || 0.to_money(currency))
  end
end
