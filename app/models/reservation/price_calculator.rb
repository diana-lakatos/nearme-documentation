class Reservation::PriceCalculator
  def initialize(reservation)
    @reservation = reservation
  end

  def total_price
    if listing.hourly_reservations?
      Reservation::HourlyPriceCalculator.new(@reservation).price
    else
      Reservation::DailyPriceCalculator.new(@reservation).price
    end
  end

  def service_fee
    subtotal_price * @reservation.service_fee_percent
  end

  def valid?
    if listing.hourly_reservations?
      Reservation::HourlyPriceCalculator.new(@reservation).valid?
    else
      Reservation::DailyPriceCalculator.new(@reservation).valid?
    end
  end

  private

    def listing
      @reservation.listing
    end
end
