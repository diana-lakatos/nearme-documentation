class ListingsController < ApplicationController
  before_filter :find_listing, :only => [:show]

  def index
    @listings = Listing.latest.paginate :page => params[:page]
  end

  def show
    @listing = Listing.find(params[:id])
    redirect_to location_url(@listing.location)
  end

  protected

  def find_listing
    @listing = Listing.find(params[:id])
  end
end
