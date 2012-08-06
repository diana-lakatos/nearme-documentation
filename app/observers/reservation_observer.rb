class ReservationObserver < ActiveRecord::Observer

  def after_create(reservation)
    if reservation.listing.confirm_reservations?
      ReservationMailer.unconfirmed_reservation_created(reservation).deliver
      ReservationMailer.pending_confirmation(reservation).deliver
    else
      ReservationMailer.confirmed_reservation_created(reservation).deliver
    end
  end

  def after_confirm(reservation, transction)
    Feed.create(:user => reservation.owner, :listing => reservation.listing, :reservation => reservation, :activity => "booked")
    ReservationMailer.reservation_confirmed(reservation).deliver
  end

  def after_reject(reservation, transaction)
    ReservationMailer.reservation_rejected(reservation).deliver
  end

  def after_user_cancel(reservation, transaction)
    ReservationMailer.reservation_cancelled_by_user(reservation).deliver
  end

  def after_owner_cancel(reservation, transaction)
    ReservationMailer.reservation_cancelled_by_owner(reservation).deliver
  end

end
