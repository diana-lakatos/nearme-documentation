class Reservation::ServiceFeeCalculator
  def initialize(reservation)
    @reservation = reservation
  end

  def service_fee_guest
    @reservation.subtotal_amount * (@reservation.service_fee_guest_percent || BigDecimal(0)) / BigDecimal(100)
  end
end
