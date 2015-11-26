class Reservation::CancellationPolicy
  def initialize(reservation)
    @reservation = reservation
    @cancel_threshold = Time.now + @reservation.cancellation_policy_hours_for_cancellation.to_i.hours
  end

  def cancelable?
    @reservation.starts_at > @cancel_threshold
  end

end
