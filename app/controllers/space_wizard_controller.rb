class SpaceWizardController < ApplicationController

  before_filter :find_user, :except => [:new]
  before_filter :find_company, :except => [:new]
  before_filter :find_location, :except => [:new]
  before_filter :find_listing, :except => [:new]

  def new
    flash.keep(:warning)
    if current_user and current_user.listings.any?
      redirect_to manage_locations_path
    elsif current_user
      event_tracker.viewed_list_your_space_list
      redirect_to space_wizard_list_url
    else
      event_tracker.viewed_list_your_space_sign_up
      redirect_to new_user_registration_url(:wizard => 'space', :return_to => space_wizard_list_path)
    end
  end

  def list
    @company ||= @user.companies.build
    @location ||= @company.locations.build
    @listing ||= @location.listings.build(
      :daily_price => 50.00
    )
  end

  def submit_listing
    @company ||= @user.companies.build
    @company.attributes = params[:company]

    if params_hash_complete? && @company.save
      if params[:uploaded_photos]
        listing = @user.first_listing
        listing.photos << current_user.photos.find(params[:uploaded_photos])
        listing.save!
      end

      event_tracker.created_a_location(@user.locations.first, { via: 'wizard' })
      event_tracker.created_a_listing(@user.first_listing, { via: 'wizard' })

      flash[:success] = 'Your space was listed! You can provide more details about your location and listing from this page.'
      redirect_to manage_locations_path
    else
      render :list
    end

  end

  def submit_photo
    @photo = Photo.new
    @photo.image = params[:company][:locations_attributes]["0"][:listings_attributes]["0"][:photos_attributes]["0"][:image]
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

    unless @user
      redirect_to new_space_wizard_url
    end
  end

  def find_company
    if current_user.companies.any?
      @company = current_user.companies.first
    end
  end

  def find_location
    if @company && @company.locations.any?
      @location = @company.locations.first
    end
  end

  def find_listing
    if @location && @location.listings.any?
      @listing = @location.listings.first
    end
  end

  def params_hash_complete?
    params[:company] && 
    params[:company][:locations_attributes] &&
    params[:company][:locations_attributes]["0"][:listings_attributes] 
  end

end
