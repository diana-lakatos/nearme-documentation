# TODO: remove 2 days after Spree removal
class ReservationExpiryJob < Job
  def after_initialize(reservation_id)
    @reservation = Order.find_by_id(reservation_id)
  end

  def perform
    @reservation.try(:perform_expiry!)
  end
end
