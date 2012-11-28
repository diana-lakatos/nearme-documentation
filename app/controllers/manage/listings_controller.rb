class Manage::ListingsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :find_listing, :except => [:index]
  before_filter :find_location

  def index
  end

  def edit
  end

  def update
    @listing.attributes = params[:listing]

    if @listing.save
      flash[:context_success] = "Great, your listing's details have been updated."
      redirect_to [:edit, :manage, @listing]
    else
      render :edit
    end
  end

  private

  def find_location
    @location = if @listing
      @listing.location
    else
      current_user.locations.find(params[:location_id])
    end
  end

  def find_listing
    @listing = current_user.listings.find(params[:id])
  end

end
