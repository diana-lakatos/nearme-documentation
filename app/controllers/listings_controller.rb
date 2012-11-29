class ListingsController < ApplicationController
  before_filter :find_listing, :only => [:show]
  before_filter :authorize_viewing!, :only => :show

  def index
    organizations = current_user ? current_user.organizations : []
    @listings = Listing.latest.with_organizations(organizations).paginate :page => params[:page]
  end

  def show
    @listing = Listing.find(params[:id])
    redirect_to location_url(@listing.location)
  end

  protected

  def find_listing
    @listing = Listing.find(params[:id])
  end

  def authorize_viewing!
    if @listing.required_organizations.any?
      unless current_user && current_user.may_view?(@listing)
        redirect_to listings_path, :alert => "Sorry, you don't have permission to view that"
      end
    end
  end
end
