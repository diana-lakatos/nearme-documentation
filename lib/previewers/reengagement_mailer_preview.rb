class ReengagementMailerPreview < MailView

  def no_bookings
    user = User.where('(current_location IS NOT NULL OR last_geolocated_location_longitude IS NOT NULL) AND instance_id IS NOT NULL').first || FactoryGirl.create(:user)
    ::ReengagementMailer.no_bookings(PlatformContext.new.initialize_with_instance(Instance.default_instance), user)
  end

  def one_booking
    ::ReengagementMailer.one_booking(PlatformContext.new.initialize_with_instance(Instance.default_instance), reservation)
  end

  private

  def reservation
    Reservation.last || FactoryGirl.create(:reservation_in_san_francisco)
  end

end
