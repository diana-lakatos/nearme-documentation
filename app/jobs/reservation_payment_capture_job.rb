class ReservationPaymentCaptureJob < Job
  def after_initialize(reservation_id)
    @reservation_id = reservation_id
  end

  def perform
    Reservation.find_by_id(@reservation_id).try(:attempt_payment_capture)
  end
end

