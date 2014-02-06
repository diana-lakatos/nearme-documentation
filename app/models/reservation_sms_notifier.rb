class ReservationSmsNotifier < SmsNotifier
  def notify_host_with_confirmation(reservation)
    return unless reservation.listing.creator.accepts_sms?
    @reservation = reservation
    sms :to => reservation.listing.creator.full_mobile_number
  end

  def notify_guest_with_state_change(reservation)
    return unless reservation.owner.accepts_sms?
    @reservation = reservation.decorate
    @platform_context = PlatformContext.new.initialize_with_company(@reservation.listing.company).decorate
    sms :to => @reservation.owner.full_mobile_number
  end
end

