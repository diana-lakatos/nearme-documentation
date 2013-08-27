class SpaceWizardController < ApplicationController

  before_filter :redirect_to_dashboard_if_user_has_listings, :only => [:new, :list]
  before_filter :find_user, :except => [:new]
  before_filter :find_company, :except => [:new, :submit_listing]
  before_filter :find_location, :except => [:new, :submit_listing]
  before_filter :find_listing, :except => [:new, :submit_listing]

  def new
    flash.keep(:warning)
    event_tracker.clicked_list_your_bookable({source: request.referer ? URI(request.referer).path : "direct"})
    if current_user
      redirect_to space_wizard_list_url
    else
      redirect_to new_user_registration_url(:wizard => 'space', :return_to => space_wizard_list_path)
    end
  end

  def list
    @company ||= @user.companies.build
    @location ||= @company.locations.build
    @listing ||= @location.listings.build
    @country =  get_user_country
    @photos = @user.photos.where("content_type = 'Listing'") || nil
    event_tracker.viewed_list_your_bookable
  end

  def submit_listing
    @user.phone_required = true
    params[:user][:companies_attributes]["0"][:instance_id] = current_instance.id.to_s
    set_listing_draft_timestamp(params[:save_as_draft] ? Time.zone.now : nil)
    @user.attributes = params[:user]
    if params[:save_as_draft]
      @user.valid? # Send .valid? message to object to trigger any validation callbacks
      @user.save(:validate => false)
      flash[:success] = 'Your draft has been saved!'
      redirect_to :list
    elsif @user.save
      track_new_space_event
      flash[:success] = 'Your space was listed! You can provide more details about your location and listing from this page.'
      redirect_to manage_locations_path
    else
      @photos = @user.first_listing ? @user.first_listing.photos : nil
      flash[:error] = 'Please complete all fields! Alternatively, you can Save a Draft for later.'
      render :list
    end
  end

  def submit_photo
    @photo = Photo.new
    @photo.image = params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"][:photos_attributes]["0"][:image]
    @photo.content_type = 'Listing'
    @photo.creator_id = current_user.id
    if @photo.save
      render :text => {:id => @photo.id, :url => @photo.image_url(:thumb).to_s, :destroy_url => destroy_space_wizard_photo_path(:id => @photo.id) }.to_json, :content_type => 'text/plain' 
    else
      render :text => [{:error => @photo.errors.full_messages}], :content_type => 'text/plain', :status => 422
    end
  end

  def destroy_photo
    @photo = current_user.photos.find(params[:id])
    if @photo.destroy
      render :text => { success: true, id: @photo.id }, :content_type => 'text/plain'
    else
      render :text => { :errors => @photo.errors.full_messages }, :status => 422, :content_type => 'text/plain'
    end
  end


  private

  def find_user
    @user = current_user
    redirect_to new_space_wizard_url unless @user
  end

  def find_company
    @company = current_user.companies.first if current_user.companies.any?
  end

  def find_location
    @location = @company.locations.first if @company && @company.locations.any?
  end

  def find_listing
    @listing = @location.listings.first if @location && @location.listings.any?
  end

  def redirect_to_dashboard_if_user_has_listings
    redirect_to manage_locations_path if current_user && current_user.listings.active.any?
  end

  def track_new_space_event
    @location = @user.locations.first
    @listing = @user.listings.first
    event_tracker.created_a_location(@location , { via: 'wizard' })
    event_tracker.created_a_listing(@listing, { via: 'wizard' })
    event_tracker.updated_profile_information(@user)
  end

  def set_listing_draft_timestamp(timestamp)
    begin
      params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"][:draft] = timestamp
    rescue
      nil
    end
  end

  def get_user_country
    @user.country_name.present? ? @user.country_name : (request.location ? request.location.country : nil)
  end

end
