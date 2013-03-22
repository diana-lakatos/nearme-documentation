require 'money-rails'

module ReservationsHelper
  include CurrencyHelper

  # Return a URL with HTTPS scheme for location reservation
  def secure_location_reservations_url(location, options = {})
    if Rails.env.production?
      options = options.reverse_merge(:protocol => "https://")
    end

    location_reservations_url(location, options)
  end

  def reservation_needs_payment_details?
    @reservations.sum(&:total_amount) > 0 && @reservations.all? { |r| r.currency == "USD" || "CAD" }
  end

  def reservation_manual_payment?
    @reservations.first.manual_payment?
  end

  def reservation_credit_card_payment?
    @reservations.first.credit_card_payment?
  end

  def reservation_schedule_for(listing, weeks = 1, &block)
    new_row = false

    listing.schedule(weeks).to_a.in_groups_of(5).each do |group|
      group.each do |date, num_of_desks|
        availability = case num_of_desks
          when 0
            "booked"
          when 1, 2, 3
            "last_reservations"
          else
            "available"
        end

        availability = "unavailable" if date.past?

        yield(date, num_of_desks, availability, new_row)
        new_row = false
      end

      new_row = true
    end
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

  def location_reservation_needs_confirmation?(reservations = @reservations)
    reservations.any? { |reservation|
      reservation.listing.confirm_reservations?
    }
  end

  def location_reservation_summaries(reservations = @reservations)
    dates = Hash.new { |h, k| h[k] = [] }
    reservations.each do |reservation|
      reservation.periods.each do |period|
        dates[period.date] << [reservation.listing, reservation.quantity]
      end
    end

    Hash[dates.keys.sort.map { |k| [k, dates[k]] }]
  end

  def location_reservation_total_amount(reservations = @reservations)
    total = reservations.sum(&:total_amount)
    "#{total.symbol}#{total}"
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

end
