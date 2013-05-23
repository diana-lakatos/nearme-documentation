class Manage::Listings::ReservationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_listing
  before_filter :find_reservation

  def confirm
    @reservation.confirm
    flash[:success] = "You have confirmed the reservation!"
    redirect_to manage_guests_dashboard_url
  end

  def reject
    @reservation.reject
    flash[:deleted] = "You have rejected the reservation. Maybe next time!"
    redirect_to manage_guests_dashboard_url
  end

  def owner_cancel
    @reservation.owner_cancel
    flash[:deleted] = "You have cancelled this reservation."
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

