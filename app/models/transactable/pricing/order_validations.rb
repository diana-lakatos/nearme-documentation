module Transactable::Pricing::OrderValidations
  def validate_order(order)
    @order = order
    action.try(:validate_order, @order)
    validate_booking_selection
    validate_book_it_out unless @order.book_it_out_discount.to_i.zero?
    validate_exclusive_price if @order.exclusive_price
  end

  def validate_book_it_out
    if !book_it_out_available? || @order.quantity < book_it_out_minimum_qty
      @order.errors.add(:base, I18n.t('reservations_review.errors.book_it_out_not_available'))
    end
  end

  def validate_exclusive_price
    unless exclusive_price_available?
      @order.errors.add(:base, I18n.t('reservations_review.errors.exclusive_price_not_available'))
    end
  end

  def validate_booking_selection
    unless price_calculator(@order).valid?
      @order.errors.add(:base, I18n.t('reservations_review.errors.no_minimum_days', minimum_days: action.minimum_booking_days))
    end
  end

  def validate_booking_selection
    unless price_calculator(@order).valid?
      if Reservation::HourlyPriceCalculator === price_calculator(@order)
        @order.errors.add(:base, I18n.t('reservations_review.errors.no_minimum_minutes', minimum_minutes: sprintf('%.2f', action.minimum_booking_minutes / 60.0)))
      else
        @order.errors.add(:base, I18n.t('reservations_review.errors.no_minimum_days', minimum_days: action.minimum_booking_days))
      end
    end
  end
end
