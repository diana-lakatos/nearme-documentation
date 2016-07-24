class MigrateAssociatedObjects < ActiveRecord::Migration
  def up
    Payment.where(payable_type: "Reservation").update_all(payable_type: "OldReservation")
    Review.where(reviewable_type: "Reservation").update_all(reviewable_type: "OldReservation")
    WaiverAgreement.where(target_type: "Reservation").update_all(target_type: "OldReservation")
    Attachable::PaymentDocument.where(attachable_type: "Reservation").update_all(attachable_type: "OldReservation")
    UserMessage.where(thread_context_type: "Reservation").update_all(thread_context_type: "OldReservation")
    AdditionalCharge.where(target_type: "Reservation").update_all(target_type: "OldReservation")

    Payment.where(payable_type: "RecurringBookingPeriod").update_all(payable_type: "OldRecurringBookingPeriod")
    PaymentSubscription.where(subscriber_type: "RecurringBooking").update_all(subscriber_type: "OldRecurringBooking")
    UserMessage.where(thread_context_type: "RecurringBooking").update_all(thread_context_type: "OldRecurringBooking")
  end

  def down
    Payment.where(payable_type: "OldReservation").update_all(payable_type: "Reservation")
    Review.where(reviewable_type: "OldReservation").update_all(reviewable_type: "Reservation")
    WaiverAgreement.where(target_type: "OldReservation").update_all(target_type: "Reservation")
    Attachable::PaymentDocument.where(attachable_type: "OldReservation").update_all(attachable_type: "Reservation")
    UserMessage.where(thread_context_type: "OldReservation").update_all(thread_context_type: "Reservation")
    AdditionalCharge.where(target_type: "OldReservation").update_all(target_type: "Reservation")

    Payment.where(payable_type: "OldRecurringBookingPeriod").update_all(payable_type: "RecurringBookingPeriod")
    PaymentSubscription.where(subscriber_type: "OldRecurringBooking").update_all(subscriber_type: "RecurringBooking")
    UserMessage.where(thread_context_type: "OldRecurringBooking").update_all(thread_context_type: "RecurringBooking")
  end
end
