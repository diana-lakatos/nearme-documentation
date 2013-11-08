class ReengagementMailerPreview < MailView

  def no_bookings
    ::ReengagementMailer.no_bookings(PlatformContext.new, User.first)
  end

  def one_booking
    ::ReengagementMailer.one_booking(PlatformContext.new, reservation)
  end

  private

  def reservation
    Reservation.last || FactoryGirl.create(:reservation_in_san_francisco)
  end

end
