class LocationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :availability_summary]
  expose :location

  def show
    @location = location
  end

  def new
    location.availability_template_id = AvailabilityRule.default_template.id
  end

  def create
    location.creator ||= current_user
    if location.save
      flash[:success] = "Successfully created location"
      redirect_to new_listing_path
    else
      flash.now[:error] = "There was a problem saving your location. Please try again"
      render :new
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
