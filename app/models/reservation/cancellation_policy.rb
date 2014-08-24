class Reservation::CancellationPolicy
  def initialize(reservation)
    @reservation = reservation
  end

  def cancelable?

    ((Time.use_zone(Time.zone) { Time.zone.local_to_utc(@reservation.date + @reservation.first_period.start_minute.minutes) }.localtime).utc > (Time.zone.now + @reservation.cancellation_policy_hours_for_cancellation.hours).utc)
  end

end
