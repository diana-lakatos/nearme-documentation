class PaymentConfirmationExpiryJob < Job

  def after_initialize(reservation_id)
    @reservation = Order.find_by_id(reservation_id)
  end

  def perform
    if @reservation.can_approve_or_decline_checkout? && @reservation.pending_guest_confirmation <= Time.zone.now
      if @reservation.payment.capture!
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::GuestApprovedPayment, @reservation.id)
        @reservation.mark_as_archived!
      else
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::GuestApprovedPaymentButCaptureFailed, @reservation.id)
      end
    end
  end
end

