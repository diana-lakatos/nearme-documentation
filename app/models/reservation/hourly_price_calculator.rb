class Reservation::HourlyPriceCalculator
  def initialize(reservation)
    @reservation = reservation
  end

  def price
    # Price is for each day, hours reserved in day * hourly price * quantity
    @reservation.periods.map { |period|
      listing.hourly_price * period.hours * @reservation.quantity
    }.sum.to_money if valid?
  end

  def valid?
    # TODO: Add minimum hourly requirement, etc.
    !@reservation.periods.empty? && @reservation.periods.all? { |p| p.hours > 0 }
  end

  private

  def listing
    @reservation.listing
  end

end

