class OfferDrop < OrderDrop

  # @return [OfferDrop]
  attr_reader :offer

  def initialize(offer)
    @order = @offer = offer
  end

  # @return [String] an empty string
  def total_units_text
    ''
  end

  # @return [String] the total amount for the offer rendered as a string using the global
  #   currency formatting options
  def formatted_total_amount
    render_money(@order.recurring_booking_periods.not_rejected.map(&:total_amount).sum)
  end

  # @return [String] the total unpaid amount for the offer rendered as a string using the
  #   global currency formatting options
  def formatted_total_unpaid_amount
    render_money(@order.recurring_booking_periods.not_rejected.unpaid.map(&:total_amount).sum)
  end

  # @return [String] the total paid amount for the offer rendered as a string using the
  #   global currency formatting options
  def formatted_total_paid_amount
    render_money(@order.recurring_booking_periods.paid.map(&:total_amount).sum)
  end
end
