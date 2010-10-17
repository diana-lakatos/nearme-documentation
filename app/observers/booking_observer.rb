class BookingObserver < ActiveRecord::Observer

  def after_create(booking)
    if booking.workplace.confirm_bookings?
      BookingMailer.unconfirmed_booking_created(booking).deliver
      BookingMailer.pending_confirmation(booking).deliver
    else
      BookingMailer.confirmed_booking_created(booking).deliver
    end
  end

  def after_confirm(booking, transction)
    Feed.create(:user => booking.user, :workplace => booking.workplace, :booking => booking, :activity => "booked")
    BookingMailer.booking_confirmed(booking).deliver
  end

end
