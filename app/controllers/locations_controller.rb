class LocationsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]
  expose :location

  def show
    @location = location
    @requested_bookings = bookings_request
    #clear_requested_bookings
  end

  def host
    @location = location
  end

  def networking
    @location = location
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
    dates = Array.wrap(params[:dates]).map { |date|
      begin
        Date.parse(date)
      rescue ArgumentError
        nil
      end
    }.compact

    render :json => location.listings.map { |listing|
      {
        :id => listing.id,
        :availability => Hash[
          dates.map { |date|
            [date.strftime("%Y-%m-%d"), { :available => listing.availability_for(date), :total => listing.quantity_for(date) }]
          }
        ]
      }
    }.to_json
  end
end
