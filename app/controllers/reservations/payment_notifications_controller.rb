class Reservations::PaymentNotificationsController < ApplicationController

  skip_before_filter :redirect_if_marketplace_password_protected

  def create
    @reservation = Reservation.find(params[:reservation_id])
    if params.has_key?("payment_provider_verifier")
      redirect_to booking_successful_reservation_path(@reservation)
    else
      @reservation.payment_response_params = params
      @reservation.charge
      render nothing: true
    end
  end
end

