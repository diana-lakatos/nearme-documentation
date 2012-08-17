module Locations
  class ListingsController < ApplicationController
    expose :location
    expose(:listing) do
      location.listings.find_by_id(params[:id]) ||
        location.listings.build(params[:listing])
    end

    def create
      listing.creator ||= current_user
      if location.save
        flash[:success] = "Successfully created listing"
        redirect_to listing_path(location)
      else
        flash.now[:error] = "There was a problem saving your location. Please try again"
        render :new
      end
    end
  end
end
