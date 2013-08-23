class Locations::ListingsController < ApplicationController
  before_filter :find_listing, :only => [:show]
  before_filter :redirect_if_listing_deleted, :only => [:show]

  def show
    # Attempt to restore a stored reservation state from the session.
    restore_initial_bookings_from_stored_reservation

    event_tracker.viewed_a_location(@location, { logged_in: user_signed_in? }) 
  end

  protected

  # Assigns the initial bookings to send to the JS controller from stored reservation request prior
  # to initiating a user session. See Locations::ReservationsController for more details
  def restore_initial_bookings_from_stored_reservation
    @initial_bookings = if params[:restore_reservations] && session[:stored_reservation_location_id] == @location.id
      session[:stored_reservation_bookings]
    end || {}
  end

  def find_listing
    @listing = Listing.with_deleted.find(params[:id])
    @location = @listing.location
  end

  def redirect_if_listing_deleted
    if @listing.deleted?
      flash[:warning] = "This listing has been removed. Displaying other listings near #{@listing.address}."
      redirect_to search_path(:q => @listing.address)
    end
  end
end
