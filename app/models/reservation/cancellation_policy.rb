class Reservation::CancellationPolicy
  def initialize(reservation)
    @reservation = reservation
    # tmp hack - we need more advanced cancellation policy - this should be pair of whether it is possible to cancel at all, and if yes, what's the penalty on any given stage.
    # For example: 7 days before it's 20% fee, 5 days before it's 40%, 2 days before it's 70% and 1 day before it's not possible at all to cancel. Currently we just can specify
    # when at latest it's possible to cancel at all, and what's the fee of cancelling at ANY given point in time. Just Hala needs to be able to charge extra if there is less than X
    # hours for booking, hence using skip_payment_authorization flag - but noted here to extend this solution.

    @cancel_threshold = Time.now + (@reservation.skip_payment_authorization? ? 0.hours : @reservation.cancellation_policy_hours_for_cancellation.to_i.hours)
  end

  def cancelable?
    @reservation.starts_at > @cancel_threshold
  end

end
