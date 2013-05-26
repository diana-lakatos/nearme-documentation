require 'money-rails'

module ReservationsHelper
  include CurrencyHelper

  # Return a URL with HTTPS scheme for listing reservation
  def secure_listing_reservations_url(listing, options = {})
    if Rails.env.production?
      options = options.reverse_merge(:protocol => "https://")
    end

    listing_reservations_url(listing, options)
  end

  def reservation_needs_payment_details?
    @reservation.total_amount > 0 && %w(USD CAD).include?(@reservation.currency)
  end

  def reservation_total_price(reservation)
    if reservation.total_amount_cents.nil?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(reservation.total_amount_cents/100.0)
    end
  end

  def reservation_paid(reservation)
    if reservation.free?
      humanized_money_with_cents_and_symbol(0.0)
    elsif reservation.paid?
      humanized_money_with_cents_and_symbol(reservation.successful_payment_amount/100.0)
    else
      reservation.payment_status.titleize
    end
  end

  def reservation_balance(reservation)
    humanized_money_with_cents_and_symbol(reservation.balance/100.0)
  end

  def reservation_dates(reservation)
    reservation.periods.map do |period|
      "#{period.date.strftime('%Y-%m-%d')} (#{pluralize(reservation.quantity, 'desk')})"
    end.to_sentence
  end

  def format_reservation_periods(reservation)
    reservation.periods.map do |period|
      period.date.strftime('%e %b')
    end.join(', ')
  end

  def location_query_string(location = @location)
    query = [location.state, location.city, location.country]
    query.reject! { |item| !item.present? || item == "Unknown" }
    query.join('%2C+')
  end

  def selected_dates_summary(reservation)
    html_string_array = reservation.periods_as_absolute_contiguous_blocks.map do |block|
      if block.size == 1
      period_to_string(block.first)
      else
        period_to_string(block.first) + ' - ' + period_to_string(block.last)
      end
    end
    (html_string_array * "<br />").html_safe
  end

  def period_to_string(date)
    date.strftime('%A, %B %e')
  end

end
