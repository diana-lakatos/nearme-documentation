class Manage::Listings::ReservationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_listing
  before_filter :find_reservation

  def update
    @reservation.fire_events(current_event)
    flash[:notice] = "You have #{@reservation.state_name} the reservation"
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

