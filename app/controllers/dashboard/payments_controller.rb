class Dashboard::UserReservations::PaymentsController <  Dashboard::BaseController
  before_filter :find_reservation
  before_filter :find_payment

  def approve
  end

  def rejection_form
  end

  def reject
  end

  private

  def find_reservation
    binding.pry
    @reservation = current_user.reservations.find(params[:user_reservation_id])
  end

  def find_payment
    @payment = reservations.payments.find(params[:id])
  end
end
