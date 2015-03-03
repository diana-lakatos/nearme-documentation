class Dashboard::Company::PaymentDocumentsController < Dashboard::Company::BaseController
  def sent_to_me
    order_ids = @company.orders.pluck(:id)
    reservation_ids = @company.reservations.pluck(:id)
    @files_sent_to_me = Attachable::PaymentDocument
      .where("(attachable_id IN (?) AND attachable_type = 'Spree::Order') OR (attachable_id IN (?) AND attachable_type = 'Reservation')", order_ids, reservation_ids)
      .paginate(page: params[:page])
  end

  def uploaded_by_me
    @files_uploaded_by_me = current_user.payment_documents.paginate(page: params[:page])
  end
end
