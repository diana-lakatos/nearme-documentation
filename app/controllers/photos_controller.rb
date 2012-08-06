class PhotosController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_listing

  def index
    @photos = @listing.photos
    @photo ||= @photos.build
  end

  def create
    @photo = @listing.photos.build(params[:photo])
    if @photo.save
      redirect_to :action => :index
    else
      index
      render :index
    end
  end

  def destroy
    @listing.photos.destroy(params[:id])
    redirect_to :action => :index
  end

  protected

  def find_listing
    @listing = current_user.listings.find(params[:listing_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to :root, :alert => "Could not find listing"
  end
end
