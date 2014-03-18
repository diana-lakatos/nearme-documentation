class ReengagementOneBookingJob < Job

  def after_initialize(reservation)
    @reservation = reservation
    @user = @reservation.owner
  end

  def perform
    ReengagementMailer.one_booking(@reservation).deliver if @reservation && (@user.reservations.count == 1)
  end
    
end
