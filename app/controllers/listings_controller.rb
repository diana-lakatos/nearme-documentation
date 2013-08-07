class ListingsController < ApplicationController
  before_filter :find_listing, :only => [:show]
  before_filter :redirect_if_listing_deleted, :only => [:show]

  def index
    @listings = Listing.latest.paginate :page => params[:page]
  end

  def show
    redirect_to location_url(@listing.location, :listing_id => params[:id])
  end

  protected

  def find_listing
    @listing = Listing.with_deleted.find(params[:id])
  end

  def redirect_if_listing_deleted
    if @listing.deleted?
      flash[:warning] = "This listing has been removed. Displaying other listings near #{@listing.address}."
      redirect_to search_path(:q => @listing.address)
    end
  end
end
