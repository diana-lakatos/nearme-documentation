class OfferDrop < OrderDrop
  attr_reader :offer

  def initialize(offer)
    @source = @order = @offer = offer
  end

  def total_units_text
    ''
  end

  def unconfirmed_or_draft?
    @offer.unconfirmed? || @offer.inactive?
  end

  def formatted_total_amount
    render_money(@order.recurring_booking_periods.not_rejected.map(&:total_amount).sum)
  end

  def formatted_total_unpaid_amount
    render_money(@order.recurring_booking_periods.not_rejected.unpaid.map(&:total_amount).sum)
  end

  def formatted_total_paid_amount
    render_money(@order.recurring_booking_periods.paid.map(&:total_amount).sum)
  end

  def offer_url
    routes.dashboard_order_path(@offer)
  end

  def edit_offer_url
    routes.edit_dashboard_order_path(@offer)
  end
end
