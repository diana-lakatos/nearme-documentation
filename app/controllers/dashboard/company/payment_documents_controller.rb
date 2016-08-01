class Dashboard::Company::PaymentDocumentsController < Dashboard::Company::BaseController
  def sent_to_me
    order_ids = @company.orders.pluck(:id)
    reservation_ids = @company.reservations.pluck(:id)
    recurring_bookings_ids = @company.recurring_bookings.pluck(:id)
    purchases_ids = @company.purchases.pluck(:id)
    @files_sent_to_me = Attachable::PaymentDocument
      .where("(attachable_id IN (?) AND attachable_type = 'Order') OR
       (attachable_id IN (?) AND attachable_type = 'Reservation') OR
       (attachable_id IN (?) AND attachable_type = 'RecurringBooking') OR
       (attachable_id IN (?) AND attachable_type = 'Purchase')", order_ids, reservation_ids, recurring_bookings_ids, purchases_ids)
      .paginate(page: params[:page])
  end

  def uploaded_by_me
    @files_uploaded_by_me = current_user.payment_documents.paginate(page: params[:page])
  end
end
