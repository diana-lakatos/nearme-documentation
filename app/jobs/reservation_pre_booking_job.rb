class ReservationPreBookingJob < Job

  def after_initialize(reservation)
    @reservation = reservation 
  end

  def perform
    ReservationMailer.pre_booking(@reservation).deliver if @reservation && @reservation.confirmed?
  end
    
end
