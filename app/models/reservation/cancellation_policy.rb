class Reservation::CancellationPolicy
  def initialize(reservation)
    @reservation = reservation
  end

  def cancelable?
    (@reservation.periods.sort { |a, b| a.date <=> b.date }.first.date > (Time.zone.now + @reservation.cancellation_policy_hours_for_cancellation.hours).utc.to_date)
  end

end
