class ReservationRefundJob < Job
  def initialize(reservation_id, counter)
    @reservation = Reservation.find_by_id(reservation_id)
    @counter = counter
  end

  def perform
    @reservation.try(:attempt_payment_refund, @counter)
  end
end

