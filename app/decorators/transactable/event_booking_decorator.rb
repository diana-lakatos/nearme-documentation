class Transactable::EventBookingDecorator < Transactable::ActionTypeDecorator
  include CurrencyHelper
  include Draper::LazyHelpers

  delegate_all

  def list_available_prices
    arr = []
    arr << "#{humanized_money_with_symbol(pricing.price)} #{I18n.t("reservations.slash_per_#{pricing.unit}")}" if pricing.price > 0
    arr << "#{humanized_money_with_symbol(pricing.exclusive_price)} / #{I18n.t("simple_form.labels.transactable.price.exclusive_price")}" if pricing.has_exclusive_price?
    arr.join(' | ')
  end

  def first_available_occurrence
    start_date = Date.strptime(params[:start_date], "%m/%d/%Y") if params[:start_date].present?
    @first_occurrence ||= next_available_occurrences(1, { start_date: start_date }).first || {}
  end

end

