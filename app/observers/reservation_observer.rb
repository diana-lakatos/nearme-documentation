class ReservationObserver < ActiveRecord::Observer

  def after_create(reservation)
    if reservation.listing.confirm_reservations?
      ReservationMailer.notify_host_with_confirmation(reservation).deliver
      ReservationMailer.notify_guest_with_confirmation(reservation).deliver
    else
      ReservationMailer.notify_host_without_confirmation(reservation).deliver
    end
  end

  def after_confirm(reservation, transction)
    ReservationMailer.notify_guest_of_confirmation(reservation).deliver
    ReservationMailer.notify_host_of_confirmation(reservation).deliver
    Track::Book.confirmed_a_booking(reservation.location.creator.id, reservation, reservation.location)
    Track::User.charge(reservation.owner.id, reservation.total_amount_dollars)
  end

  def after_reject(reservation, transaction)
    ReservationMailer.notify_guest_of_rejection(reservation).deliver
    Track::Book.rejected_a_booking(reservation.location.creator.id, reservation, reservation.location)
  end

  def after_user_cancel(reservation, transaction)
    ReservationMailer.notify_host_of_cancellation(reservation).deliver
    Track::Book.cancelled_a_booking(reservation.location.creator.id, 'host', reservation, reservation.location)
    Track::User.charge(reservation.owner.id, reservation.total_negative_amount_dollars)
  end

  def after_owner_cancel(reservation, transaction)
    ReservationMailer.notify_guest_of_cancellation(reservation).deliver
    Track::Book.cancelled_a_booking(reservation.owner.id, 'guest', reservation, reservation.location)
    Track::User.charge(reservation.owner.id, reservation.total_negative_amount_dollars)
  end

  def after_expire(reservation, transaction)
    ReservationMailer.notify_guest_of_expiration(reservation).deliver
    ReservationMailer.notify_host_of_expiration(reservation).deliver
    Track::Book.booking_expired(reservation.location.creator.id, reservation, reservation.location)
  end

end
