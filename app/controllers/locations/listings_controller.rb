class Locations::ListingsController < ApplicationController
  before_filter :find_listing, :only => [:show]

  def show
    redirect_to location_path(@location, @listing), :status => :moved_permanently
  end

  protected

  def find_listing
    @listing = Transactable.find(params[:id])
    @location = Location.find(@listing.location_id)
  end

end
