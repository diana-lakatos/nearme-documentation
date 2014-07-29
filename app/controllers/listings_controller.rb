class ListingsController < ApplicationController
  before_filter :redirect_if_invalid_page_param, :only => [:index]
  before_filter :find_listing, :only => [:show]

  def index
    @listings = Transactable.latest.includes(:location).paginate(:page => params[:page])
  end

  def show
    redirect_to location_listing_path(@location, @listing), :status => :moved_permanently
  end

  protected

  def redirect_if_invalid_page_param
    unless params[:page] && params[:page].match(/^[0-9]*[1-9][0-9]*$/)
      redirect_to listings_path(:page =>1), :flash => { :warning => "Requested page does not exist, showing first page." }, :status => :moved_permanently
    end
  end

  def find_listing
    @listing = Transactable.with_deleted.find(params[:id])
    @location = Location.with_deleted.find(@listing.location_id)
  end

end
