class LocationsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :require_ssl, :only => :show

  def show
    @location = Location.find(params[:id])
    @listing = @location.listings.find(params[:listing_id]) if params[:listing_id]

    # Attempt to restore a stored reservation state from the session.
    restore_initial_bookings_from_stored_reservation

    Track::Search.viewed_a_location(current_user_id, user_signed_in?, @location)
  end

  private

  # Assigns the initial bookings to send to the JS controller from stored reservation request prior
  # to initiating a user session. See Locations::ReservationsController for more details
  def restore_initial_bookings_from_stored_reservation
    @initial_bookings = if params[:restore_reservations] && session[:stored_reservation_location_id] == @location.id
      session[:stored_reservation_bookings]
    end || {}
  end

end

