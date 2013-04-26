class Manage::ListingsController < Manage::BaseController

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
      if params[:uploaded_photos]
        @listing.photos << current_user.photos.find(params[:uploaded_photos])
        @listing.save!
      end
      flash[:notice] = "Great, your new Desk/Room has been added!"
      redirect_to manage_locations_path
    else
      render :new
    end
  end

  def show
    redirect_to edit_manage_location_listing_path(@location, @listing)
  end

  def edit
  end

  def update
    @listing.attributes = params[:listing]

    if @listing.save
      flash[:notice] = "Great, your listing's details have been updated."
      redirect_to manage_locations_path
    else
      render :edit
    end
  end

  def destroy
    @listing.destroy

    flash[:notice] = "That listing has been deleted."
    redirect_to manage_locations_path
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
