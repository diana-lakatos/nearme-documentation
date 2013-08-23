class ListingsController < ApplicationController
  before_filter :find_listing, :only => [:show]

  def index
    @listings = Listing.latest.paginate :page => params[:page]
  end

  def show
    redirect_to location_listing_path(@location, @listing)
  end

  protected

  def find_listing
    @listing = Listing.with_deleted.find(params[:id])
    @location = @listing.location
  end

end
