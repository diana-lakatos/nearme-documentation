module GlobalAdmin::ReservationsHelper
  def admin_reservation_state_label_class(reservation)
    case reservation.state
    when 'cancelled_by_guest'
      'inverse'
    when 'cancelled_by_host'
      'inverse'
    when 'unconfirmed'
      'warning'
    when 'confirmed'
      'success'
    when 'rejected'
      'important'
    end
  end
end
