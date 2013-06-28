class Reservation::PriceCalculator
  def initialize(reservation)
    @reservation = reservation
    if @reservation.listing.hourly_reservations?
      @subprice_calculator = Reservation::HourlyPriceCalculator.new(@reservation)
    else
      @subprice_calculator = Reservation::DailyPriceCalculator.new(@reservation)
    end
  end

  def total_price
    subtotal_price + service_fee
  end

  def subtotal_price
    @subprice_calculator.price
  end

  def service_fee
    subtotal_price * (@reservation.service_fee_percent || BigDecimal(0)) / BigDecimal(100)
  end

  def valid?
    @subprice_calculator.valid?
  end

  private

    def listing
      @reservation.listing
    end
end
