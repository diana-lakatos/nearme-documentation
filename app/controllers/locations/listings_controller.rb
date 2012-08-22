module Locations
  class ListingsController < ApplicationController
    before_filter :find_listing, :only => [:new, :create]

    def new
      render :template => "listings/new"
    end

    def create
      @listing.creator ||= current_user
      if @location.save
        flash[:success] = "Successfully created listing"
        redirect_to listing_path(@location)
      else
        flash.now[:error] = "There was a problem saving your location. Please try again"
        render :template => "listings/new"
      end
    end

    def find_listing
      @location = Location.find_by_id(params[:location_id])
      @listing = @location.listings.find_by_id(params[:id]) ||
        @location.listings.build(params[:listing])
    end
  end
end
