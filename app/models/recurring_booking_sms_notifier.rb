class RecurringBookingSmsNotifier < SmsNotifier
  def notify_host_with_confirmation(recurring_booking)
    return unless recurring_booking.creator.accepts_sms_with_type?(:new_reservation)
    @recurring_booking = recurring_booking
    sms :to => recurring_booking.creator.full_mobile_number, :fallback => { :email => @recurring_booking.host.email }
  end

  def notify_guest_with_state_change(recurring_booking)
    return unless recurring_booking.owner.accepts_sms_with_type?(:reservation_state_changed)
    @recurring_booking = recurring_booking.decorate
    sms :to => @recurring_booking.owner.full_mobile_number, :fallback => { :email => recurring_booking.owner.email }
  end

end

