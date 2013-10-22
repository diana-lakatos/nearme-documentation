class ReservationPreBookingJob < Job

  def initialize(platform_context, reservation)
    @reservation = reservation 
    @platform_context = platform_context
  end

  def perform
    ReservationMailer.pre_booking(@platform_context, @reservation).deliver if @reservation && @reservation.confirmed?
  end
    
end
