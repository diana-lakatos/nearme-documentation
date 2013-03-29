class LocationsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :require_ssl, :only => :show

  def show
    @location = Location.find(params[:id])
    @listing = @location.listings.find(params[:listing_id]) if params[:listing_id]

    # Attempt to restore a stored reservation state from the session.
    if params[:restore_reservations]
      restore_initial_bookings_from_stored_reservation
    end
  end

  # Return a summary in JSON for all listings availability over specified days
  #
  # Usage:
  #   GET /locations/id/availability_summary?dates[]=2012-11-13&dates[]=2012-11-14&dates[]=2012-11-15
  #
  # Response:
  #   [
  #     { id: "1", availability: {
  #       "2012-11-13" : { available: 10, total: 10 },
  #       "2012-11-14" : { available: 2, total: 10 },
  #       "2012-11-14" : { available: 0, total: 10 }
  #     },
  #     ...
  #   ]
  #
  def availability_summary
    @location = Location.find(params[:id])

    dates = Array.wrap(params[:dates]).map { |date|
      begin
        Date.parse(date)
      rescue ArgumentError
        nil
      end
    }.compact

    render :json => @location.listings.map { |listing|
      {
        :id => listing.id,
        :availability => Hash[
          dates.map { |date|
            [date.strftime("%Y-%m-%d"), { :available => listing.availability_for(date), :total => listing.quantity_for(date), :open => listing.open_on?(date) }]
          }
        ]
      }
    }.to_json
  end

  private

  # Assigns the initial bookings to send to the JS controller from stored reservation request prior
  # to initiating a user session. See Locations::ReservationsController for more details
  def restore_initial_bookings_from_stored_reservation
    if session[:stored_reservation_location_id] == @location.id
      @initial_bookings = session[:stored_reservation_bookings]
    end
  end

end
