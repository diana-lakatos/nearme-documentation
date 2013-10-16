class Locations::ListingsController < ApplicationController
  before_filter :find_listing, :only => [:show]
  before_filter :redirect_if_listing_inactive, :only => [:show]

  def show
    # Attempt to restore a stored reservation state from the session.
    restore_initial_bookings_from_stored_reservation

    # Store location visit
    @location.track_impression(request.remote_ip)

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

  def redirect_if_listing_inactive
    if @listing.deleted? || @listing.draft?
      flash[:warning] = t('listings.listing_inactive', address: @listing.address)
      redirect_to search_path(:q => @listing.address)
    end

    if !@listing.enabled? && (!user_signed_in? || !@listing.company.company_users.where(user_id: current_user.id).any?)
      flash[:warning] = t('listings.listing_disabled')
      redirect_to search_path(:q => @listing.address)
    end
  end
end
