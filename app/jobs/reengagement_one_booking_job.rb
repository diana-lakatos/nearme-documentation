class ReengagementOneBookingJob < Job

  def after_initialize(reservation_id)
    @reservation_id = reservation_id
  end

  def perform
    @reservation = Reservation.find_by_id(@reservation_id)
    if @reservation
      @user = @reservation.owner
      if @user.reservations.count == 1 && @user.listings_in_near.size > 0
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::OneBookingSuggestions, @reservation_id) if @reservation.confirmed?
      end
    end
  end
end
