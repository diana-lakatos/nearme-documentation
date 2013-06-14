class ReservationObserver < ActiveRecord::Observer

  def after_create(reservation)
    if reservation.listing.confirm_reservations?
      ReservationMailer.notify_host_with_confirmation(reservation).deliver
      ReservationMailer.notify_guest_with_confirmation(reservation).deliver
      ReservationSmsNotifier.notify_host_with_confirmation(reservation).deliver
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
  
  def after_expire(reservation, transaction)
    ReservationMailer.notify_guest_of_expiration(reservation).deliver
    ReservationMailer.notify_host_of_expiration(reservation).deliver
    track_expire_event(reservation)
  end
  
  private
  
  def track_expire_event(reservation)
    tracker = Mixpanel::Tracker.new MIXPANEL_TOKEN
    tracker.track 'Reservation Expired (Host)', { distinct_id: reservation.listing.creator.id }
    tracker.track 'Reservation Expired (Guest)', { distinct_id: reservation.owner_id }
  rescue
    nil
  end
  
  

end
