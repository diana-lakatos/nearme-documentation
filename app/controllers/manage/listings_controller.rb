class Manage::ListingsController < Manage::BaseController

  before_filter :set_locations_scope
  before_filter :find_listing, :except => [:index, :new, :create]
  before_filter :find_location

  def index
    redirect_to new_manage_location_listing_path(@location)
  end

  def new
    @listing = @location.listings.build(
      :daily_price_cents => 50_00,
      :availability_template_id => AvailabilityRule.default_template.id
    )

  end

  def create
    @listing = @location.listings.build(params[:listing])

    if @listing.save
      flash[:success] = t('flash_messages.manage.listings.desk_added')
      event_tracker.created_a_listing(@listing, { via: 'dashboard' })
      event_tracker.updated_profile_information(current_user)
      redirect_to manage_locations_path
    else
      @photos = @listing.photos
      render :new
    end
  end

  def show
    redirect_to edit_manage_location_listing_path(@location, @listing)
  end

  def edit
    @photos = @listing.photos

    event_tracker.mailer_upload_photos_now_clicked(@listing) if params[:track_email_event]
  end

  def update
    respond_to do |format|
      format.html {
        if @listing.update_attributes params[:listing]
          flash[:success] = t('flash_messages.manage.listings.listing_updated')
          redirect_to manage_locations_path
        else
          @photos = @listing.photos
          render :edit
        end
      }
      format.json {
        if @listing.update_attributes(params[:listing])
          render :json => { :success => true }
        else
          render :json => { :errors => @listing.errors.full_messages }, :status => 422
        end
      }
    end
  end

  def enable
    if @listing.enable!
      render :json => { :success => true }
    else
      render :json => { :errors => @listing.errors.full_messages }, :status => 422
    end
  end

  def disable
    if @listing.disable!
      render :json => { :success => true }
    else
      render :json => { :errors => @listing.errors.full_messages }, :status => 422
    end
  end

  def destroy
    @listing.reservations.each do |r|
      r.perform_expiry!(platform_context)
    end
    @listing.destroy
    event_tracker.updated_profile_information(current_user)
    flash[:deleted] = t('flash_messages.manage.listings.listing_deleted')
    redirect_to manage_locations_path
  end

  private

  def find_location
    begin 
      @location = if @listing
                    @listing.location
                  else
                    @locations_scope.find(params[:location_id])
                  end
    rescue ActiveRecord::RecordNotFound
      raise Manage::LocationNotFound
    end
  end

  def find_listing
    begin 
      @listing = Listing.where(location_id: @locations_scope.pluck(:id)).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise Manage::ListingNotFound
    end
  end
end
