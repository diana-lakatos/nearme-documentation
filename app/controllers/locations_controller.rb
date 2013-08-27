class LocationsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :find_location, :only => :show
  before_filter :redirect_if_location_deleted, :only => :show
  before_filter :redirect_for_location_custom_page, :only => :show

  def show
    if @location.listings.active.empty?
      # If location doesn't have any listings, redirects to search page with notice
      flash[:warning] = "There aren't any listings at that location. Check out some other spaces!"
      redirect_to search_path 
    else
      if @location.listings.active.find(params[:listing_id])
        redirect_to location_listing_path(@location, params[:listing_id])
      else
        # Redirect to location with first listing
        redirect_to location_listing_path(@location, @location.listings.active.first)
      end
    end
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
    @location = Location.with_deleted.find(params[:id])
  end

  def redirect_if_location_deleted
    if @location.deleted?
      flash[:warning] =  "This listing has been removed. Displaying other listings near #{@location.address}."
      redirect_to search_path(:q => @location.address)
    end
  end

  def redirect_for_location_custom_page
    case @location.custom_page
    when "w_hotels"
      redirect_to(w_hotels_location_url(:restore_reservations => params[:restore_reservations]))
    end
  end

end

