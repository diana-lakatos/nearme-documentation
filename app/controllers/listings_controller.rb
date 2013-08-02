class ListingsController < ApplicationController
  before_filter :find_listing, :only => [:show]

  def index
    @listings = Listing.latest.paginate :page => params[:page]
  end

  def show
    redirect_to location_url(@listing.location, :listing_id => params[:id])
  end

  protected

  def find_listing
    begin
      @listing = Listing.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @deleted_listing = Listing.only_deleted.find(params[:id])
      @location = Location.with_deleted.find(@deleted_listing.location_id)
      flash[:warning] =  "This listing has been removed. Displaying other listings near #{@location.address}."
      redirect_to search_path(:q => @location.address)
    end
  end
end
