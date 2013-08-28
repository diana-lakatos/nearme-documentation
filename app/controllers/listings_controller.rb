class ListingsController < ApplicationController
  before_filter :sanitize_page_param, :only => [:index]
  before_filter :find_listing, :only => [:show]

  def index
    @listings = Listing.latest.paginate :page => params[:page]
  end

  def show
    redirect_to location_listing_path(@location, @listing)
  end

  protected

  def sanitize_page_param
    if params[:page] && params[:page].to_i == 0
      redirect_to listings_path(:page =>1), :flash => { :warning => "Requested page does not exist, showing first page." }
    end
  end

  def find_listing
    @listing = Listing.with_deleted.find(params[:id])
    @location = @listing.location
  end

end
