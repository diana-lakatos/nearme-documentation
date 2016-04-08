class Reservation::HourlyPriceCalculator
  def initialize(reservation)
    @reservation = reservation
  end

  def price
    # Price is for each day, hours reserved in day * hourly price * quantity
    @reservation.periods.map { |period|
      (@reservation.unit_price.to_f.zero? ? listing.hourly_price : @reservation.unit_price) * period.hours * @reservation.quantity
    }.sum.to_money
  end

  def valid?
    !@reservation.periods.empty? && @reservation.periods.all? { |p| p.hours > 0 && @reservation.minimum_booking_minutes <= p.minutes }
  end

  def unit_price
    listing.hourly_price
  end

  private

  def listing
    @reservation.listing
  end

end

