module Admin::ReservationsHelper
  def admin_reservation_state_label_class(reservation)
    case reservation.state
    when 'cancelled'
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

