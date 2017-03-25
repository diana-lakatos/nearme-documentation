class Transactable::ActionTypeDecorator < Draper::Decorator
  include CurrencyHelper

  delegate_all

  def list_available_prices
    pricings.map do |pricing|
      if pricing.is_free_booking?
        "#{I18n.t('booking_module.free')} #{pricing.decorate.units_translation('reservations.per_unit_price')}"
      else
        "#{I18n.t('reservations.from_price')} #{render_money(pricing.price)} #{I18n.t("reservations.slash_per_#{pricing.unit}")}"
      end
    end.join(' | ')
  end

  def availabile_units_with_i18n
    available_units.map do |unit|
      [I18n.t("pricing.#{unit}", count: 1), unit]
    end
  end

  def price_with_currency(pricing = pricings.first)
    render_money pricing.price
  end

  def exclusive_price_with_currency(pricing = pricings.first)
    render_money pricing.exclusive_price
  end

  def show_end_date?
    pricings.any? { |p| p.unit =~ /day|night/ }
  end

  def show_time_picker?
    pricings.any?(&:hour_booking?)
  end

  #TODO: remove after FormConfiguration
  def pricings_for_form
    all_pricings = []
    transactable_type_action_type.pricings.ordered_by_unit.each do |tt_pricing|
      all_pricings << (pricings.find { |p| p.transactable_type_pricing_id == tt_pricing.id }.presence || tt_pricing.build_transactable_pricing(object))
    end
    all_pricings << pricings.select { |p| p.transactable_type_pricing_id.nil? && p.persisted? }
    all_pricings = all_pricings.flatten.compact.sort { |a, b| [a.unit, a.number_of_units] <=> [b.unit, b.number_of_units] }
    all_pricings + pricings.select { |p| p.transactable_type_pricing_id.nil? && p.new_record? }
  end
end
