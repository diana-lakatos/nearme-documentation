class ReservationMarkAsArchivedJob < Job

  def after_initialize(reservation_id)
    @reservation = Reservation.find_by_id(reservation_id)
  end

  def perform
    @reservation.mark_as_archived!
  end
end

