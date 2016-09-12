class OfferDrop < OrderDrop

  attr_reader :offer

  def initialize(offer)
    @order = @offer = offer
  end

  def total_units_text
    ''
  end

  def formatted_total_amount
    humanized_money_with_cents_and_symbol(@order.recurring_booking_periods.not_rejected.map(&:total_amount).sum)
  end

  def formatted_total_unpaid_amount
    humanized_money_with_cents_and_symbol(@order.recurring_booking_periods.not_rejected.unpaid.map(&:total_amount).sum)
  end

  def formatted_total_paid_amount
    humanized_money_with_cents_and_symbol(@order.recurring_booking_periods.paid.map(&:total_amount).sum)
  end

end
