class Manage::Listings::ReservationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_listing
  before_filter :find_reservation

  def confirm
    if @reservation.confirm
      ReservationMailer.notify_guest_of_confirmation(@reservation).deliver
      ReservationMailer.notify_host_of_confirmation(@reservation).deliver
      event_tracker.confirmed_a_booking(@reservation, @reservation.location)
      event_tracker.charge(@reservation.owner.id, @reservation.total_amount_dollars)
      flash[:success] = "You have confirmed the reservation!"
    else
      flash[:error] = "Your reservation could not be confirmed."
    end
    redirect_to manage_guests_dashboard_url
  end

  def reject
    if @reservation.reject
      ReservationMailer.notify_guest_of_rejection(@reservation).deliver
      event_tracker.rejected_a_booking(@reservation, @reservation.location)
      flash[:deleted] = "You have rejected the reservation. Maybe next time!"
    else
      flash[:error] = "Your reservation could not be confirmed."
    end
    redirect_to manage_guests_dashboard_url
  end

  def host_cancel
    if @reservation.host_cancel
      ReservationMailer.notify_guest_of_cancellation(@reservation).deliver
      event_tracker.cancelled_a_booking(@reservation, @reservation.location, { actor: 'host' })
      event_tracker.charge(@reservation.owner.id, @reservation.total_negative_amount_dollars)
      flash[:deleted] = "You have cancelled this reservation."
    else
      flash[:error] = "Your reservation could not be confirmed."
    end
    redirect_to manage_guests_dashboard_url
  end

  private

  def find_listing
    @listing = current_user.listings.find(params[:listing_id])
  end

  def find_reservation
    @reservation = @listing.reservations.find(params[:id])
  end

  def current_event
    params[:event].downcase.to_sym
  end
end

