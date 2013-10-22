class ReengagementOneBookingJob < Job

  def initialize(platform_context, reservation)
    @platform_context = platform_context 
    @reservation = reservation
    @user = @reservation.owner
  end

  def perform
    ReengagementMailer.one_booking(@platform_context, @reservation).deliver if @reservation && (@user.reservations.count == 1)
  end
    
end
