class Manage::PhotosController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_listing
  before_filter :find_photo, :except => [:index, :create]

  def index
  end

  def create
    @photo = @listing.photos.build(params[:photo])

    if @photo.save
      flash[:context_success] = "Great, your photo has been added."
      redirect_to [:manage, @listing, :photos]
    else
      render :index
    end
  end

  def destroy
    @photo.destroy

    flash[:context_success] = "That photo has been removed."
    redirect_to [:manage, @listing, :photos]
  end

  private

  def find_listing
    @listing = current_user.listings.find(params[:listing_id])
    @location = @listing.location
  end

  def find_photo
    @photo = @listing.photos.find(params[:id])
  end
end
