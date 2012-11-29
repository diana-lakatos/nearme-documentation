class Manage::ListingsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :find_listing, :except => [:index, :new, :create]
  before_filter :find_location

  def index
  end

  def new
    @listing = @location.listings.build
  end

  def create
    @listing = @location.listings.build(params[:listing])

    if @listing.save
      flash[:context_success] = "Great, your new Desk/Room has been added!"
      redirect_to [:edit, :manage, @listing]
    else
      render :new
    end
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

  def destroy
    @listing.destroy

    flash[:context_success] = "That listing has been deleted."
    redirect_to [:manage, @location, :listings]
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
