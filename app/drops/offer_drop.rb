class OfferDrop < OrderDrop

  attr_reader :offer

  def initialize(offer)
    @order = @offer = offer
  end

  def total_units_text
    ''
  end

  def formatted_total_amount
    humanized_money_with_cents_and_symbol(@order.recurring_booking_periods.map(&:total_amount).sum)
  end

  def formatted_total_unpaid_amount
    humanized_money_with_cents_and_symbol(@order.recurring_booking_periods.unpaid.map(&:total_amount).sum)
  end

  def formatted_total_paid_amount
    humanized_money_with_cents_and_symbol(@order.recurring_booking_periods.paid.map(&:total_amount).sum)
  end

  def offer_url
    routes.dashboard_order_url(@offer)
  end

  def edit_offer_url
    routes.edit_dashboard_order_url(@offer)
  end

end
