class Locations::ListingsController < ApplicationController
  before_filter :find_listing, :only => [:show]

  def show
    redirect_to location_path(@location, @listing)
  end

  protected

  def find_listing
    @listing = Transactable.with_deleted.find(params[:id])
    @location = @listing.location
  end

end
