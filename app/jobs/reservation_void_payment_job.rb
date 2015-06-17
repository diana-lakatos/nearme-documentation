class ReservationVoidPaymentJob < Job
  def after_initialize(reservation_id)
    @reservation_id = reservation_id
  end

  def perform
    @reservation = Reservation.with_deleted.find_by_id(@reservation_id)
    if (@reservation.expired? || @reservation.rejected? || @reservation.cancelled_by_guest?) && @reservation.active_merchant_payment?
      @reservation.billing_authorization.void!
    end
  end
end

