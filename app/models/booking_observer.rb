class BookingObserver < ActiveRecord::Observer

  def after_create(booking)
    booking.confirm! unless booking.workplace.confirm_bookings?
  end

  def after_confirm(booking, transction)
    Feed.create(:user => booking.user, :workplace => booking.workplace, :booking => booking, :activity => "booked")
  end

end
