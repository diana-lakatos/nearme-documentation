module ReservationsHelper
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
      humanized_money_with_symbol(reservation.total_amount_cents/100.0)
    end
  end

  def reservation_dates(reservation)
    reservation.periods.map do |period|
      "#{period.date.strftime('%Y-%m-%d')} (#{pluralize(period.seats.size, 'desk')})"
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
        dates[period.date] << [reservation.listing, period.quantity]
      end
    end

    Hash[dates.keys.sort.map { |k| [k, dates[k]] }]
  end

  def location_reservation_total_amount(reservations = @reservations)
    total = reservations.sum(&:total_amount)
    "#{total.symbol}#{total}"
  end
end
