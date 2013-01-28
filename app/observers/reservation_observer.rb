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
  end

  def after_reject(reservation, transaction)
    ReservationMailer.notify_guest_of_rejection(reservation).deliver
  end

  def after_user_cancel(reservation, transaction)
    ReservationMailer.notify_host_of_cancellation(reservation).deliver
  end

  def after_owner_cancel(reservation, transaction)
    ReservationMailer.notify_guest_of_cancellation(reservation).deliver
  end

end
