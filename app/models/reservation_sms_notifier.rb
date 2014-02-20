class ReservationSmsNotifier < SmsNotifier
  def notify_host_with_confirmation(reservation)
    return unless reservation.creator.accepts_sms_with_type?(:new_reservation)
    @reservation = reservation
    sms :to => reservation.creator.full_mobile_number
  end

  def notify_guest_with_state_change(reservation)
    return unless reservation.owner.accepts_sms_with_type?(:reservation_state_changed)
    @reservation = reservation.decorate
    @platform_context = PlatformContext.new.initialize_with_company(@reservation.company).decorate
    sms :to => @reservation.owner.full_mobile_number
  end
end

