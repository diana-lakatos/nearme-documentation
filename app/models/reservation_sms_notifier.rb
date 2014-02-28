class ReservationSmsNotifier < SmsNotifier
  def notify_host_with_confirmation(platform_context, reservation)
    return unless reservation.creator.accepts_sms_with_type?(:new_reservation)
    @reservation = reservation
    sms :to => reservation.creator.full_mobile_number, :fallback => { :email => @reservation.host.email, :platform_context => platform_context }
  end

  def notify_guest_with_state_change(platform_context, reservation)
    return unless reservation.owner.accepts_sms_with_type?(:reservation_state_changed)
    @reservation = reservation.decorate
    @platform_context = platform_context.decorate
    sms :to => @reservation.owner.full_mobile_number, :fallback => { :email => reservation.owner.email, :platform_context => @platform_context }
  end
end

