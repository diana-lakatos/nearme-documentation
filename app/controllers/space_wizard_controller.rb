class SpaceWizardController < ApplicationController

  before_filter :find_user, :except => [:new]
  before_filter :find_company, :except => [:new]
  before_filter :find_location, :except => [:new]
  before_filter :find_listing, :except => [:new]

  def new
    flash.keep(:notice)
    if current_user
      redirect_to space_wizard_list_url
    else
      redirect_to new_user_registration_url(:wizard => 'space')
    end
  end

  def list
    @company ||= @user.companies.build
    @location ||= @company.locations.build
    @listing ||= @location.listings.build
  end

  def submit_listing
    @company ||= @user.companies.build
    @company.attributes = params[:company]

    if @company.save
      if params[:uploaded_photos]
        listing = @company.locations.first.listings.first
        listing.photos << current_user.photos.find(params[:uploaded_photos])
        listing.save!
      end
      redirect_to controlpanel_path, notice: 'Your space was listed! You can provide more details about your location and listing from this page.'
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

end
