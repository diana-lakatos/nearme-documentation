class LocationsController < ApplicationController
  before_filter :authenticate_user!
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
end
