class Reservation::ServiceFeeCalculator
  def initialize(reservation)
    @reservation = reservation
  end

  def service_fee
    @reservation.subtotal_amount * (@reservation.service_fee_percent || BigDecimal(0)) / BigDecimal(100)
  end
end
