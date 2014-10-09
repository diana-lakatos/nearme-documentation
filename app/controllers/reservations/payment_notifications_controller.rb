class Reservations::PaymentNotificationsController < ApplicationController

  skip_before_filter :redirect_if_marketplace_password_protected

  def create
    @reservation = Reservation.find(params[:reservation_id])
    if params.has_key?("payment_provider_verifier")
      redirect_to booking_successful_reservation_path(@reservation)
    elsif params.has_key?("verifier")
      @reservation.payment_response_params = params
      @reservation.charge
      render nothing: true
    else
      redirect_to booking_failed_reservation_path(@reservation)
    end
  end
end

