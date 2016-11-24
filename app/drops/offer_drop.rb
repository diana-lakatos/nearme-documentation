# frozen_string_literal: true
class OfferDrop < OrderDrop
  # @return [OfferDrop]
  attr_reader :offer

  def initialize(offer)
    @source = @order = @offer = offer
  end

  # @return [String] an empty string
  # @todo -- EXTERMINATE EXTERMINATE EXTERMINATE
  def total_units_text
    ''
  end

  # @return [Boolean] whether the offer is unconfirmed or draft (inactive status)
  # @todo -- deprecate - DIY
  def unconfirmed_or_draft?
    @offer.unconfirmed? || @offer.inactive?
  end

  # @return [String] the total amount for the offer rendered as a string using the global
  #   currency formatting options
  # @todo -- deprecate -- format using filter
  def formatted_total_amount
    render_money(@order.recurring_booking_periods.not_rejected.map(&:total_amount).sum)
  end

  # @return [String] the total unpaid amount for the offer rendered as a string using the
  #   global currency formatting options
  # @todo -- deprecate -- format using filter
  def formatted_total_unpaid_amount
    render_money(@order.recurring_booking_periods.not_rejected.unpaid.map(&:total_amount).sum)
  end

  # @return [String] the total paid amount for the offer rendered as a string using the
  #   global currency formatting options
  # @todo -- deprecate -- format using filter
  def formatted_total_paid_amount
    render_money(@order.recurring_booking_periods.paid.map(&:total_amount).sum)
  end

  # @return [String] url to the offer in the user's dashboard
  # @todo -- deprecate -- filter url
  def offer_url
    routes.dashboard_order_path(@offer)
  end

  # @return [String] url to edit the offer in the user's dashboard
  # @todo -- deprecate -- filter url
  def edit_offer_url
    routes.edit_dashboard_order_path(@offer)
  end
end
