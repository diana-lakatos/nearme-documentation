class LocationsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :require_ssl, :only => :show
  before_filter :find_location, :only => :show
  before_filter :redirect_for_location_custom_page, :only => :show

  def show
    @listing = @location.listings.find(params[:listing_id]) if params[:listing_id]

    # Attempt to restore a stored reservation state from the session.
    restore_initial_bookings_from_stored_reservation
  end

  def w_hotels
    @location = Location.find_by_custom_page("w_hotels")
    @listing = @location.listings.first
    
    restore_initial_bookings_from_stored_reservation
  end

  private

  # Assigns the initial bookings to send to the JS controller from stored reservation request prior
  # to initiating a user session. See Locations::ReservationsController for more details
  def restore_initial_bookings_from_stored_reservation
    @initial_bookings = if params[:restore_reservations] && session[:stored_reservation_location_id] == @location.id
      session[:stored_reservation_bookings]
    end || {}
  end

  def find_location
    @location = Location.find(params[:id])
  end

  def redirect_for_location_custom_page
    case @location.custom_page
    when "w_hotels"
      redirect_to(w_hotels_location_url(:restore_reservations => params[:restore_reservations]))
    end
  end

end
