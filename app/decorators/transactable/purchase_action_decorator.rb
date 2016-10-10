class Transactable::PurchaseActionDecorator < Transactable::ActionTypeDecorator
  include CurrencyHelper
  include Draper::LazyHelpers

  delegate_all

  def list_available_prices
    arr = []
    arr << "#{render_money(pricing.price)} #{I18n.t("reservations.slash_per_#{pricing.unit}")}" if pricing.price > 0
    arr.join(' | ')
  end
end
