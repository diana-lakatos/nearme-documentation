class Reservation::CancellationPolicy
  def initialize(reservation)
    @reservation = reservation
  end

  def cancelable?
    ((@reservation.date + @reservation.first_period.start_minute.minutes).utc > (Time.zone.now + @reservation.cancellation_policy_hours_for_cancellation.hours).utc)
  end

end
