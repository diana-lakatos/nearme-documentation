class Manage::PhotosController < ApplicationController

  before_filter :get_proper_hash, :only => [:create]

  def create
    @photo = Photo.new
    @photo.image = @image
    @photo.content = @content
    @photo.content_type = @content_type
    @photo.creator_id = current_user.id
    if @photo.save
      render :text => {
        :id => @photo.id, 
        :url => @photo.image_url(get_image_url).to_s,
        :destroy_url => destroy_space_wizard_photo_path(@photo),
        :resize_url =>  edit_manage_photo_path(@photo)
      }.to_json, 
      :content_type => 'text/plain' 
    else
      render :text => [{:error => @photo.errors.full_messages}], :content_type => 'text/plain', :status => 422
    end
  end

  def edit
    @photo = current_user.photos.find(params[:id])
    if request.xhr?
      render partial: 'resize_form'
    end
  end

  def update
    @photo = current_user.photos.find(params[:id])
    if @photo.update_attributes(params[:photo])
      render json: {hide: true}
    else
      render partial: 'resize_form'
    end
  end

  def destroy
    @photo = current_user.photos.find(params[:id])
    if @photo.destroy
      render :text => { success: true, id: @photo.id }, :content_type => 'text/plain'
    else
      render :text => { :errors => @photo.errors.full_messages }, :status => 422, :content_type => 'text/plain'
    end
  end


  private

  def get_proper_hash
    # we came from list your space flow
    if params[:user]
      @param = params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"]
      @content_type = 'Listing'
      @content = nil
    # we came from dashboard
    else 
      Photo::AVAILABLE_CONTENT.each do |content|
        @param = params[content.downcase.to_sym]
        if @param
          @content_type = content
          @content = @param[:id].present? ? current_user.send(content.pluralize.downcase.to_sym).find(@param[:id]) : nil
          break
        end
      end
      raise 'Unknown path to photos_attributes' unless @content_type
    end
    @image = @param[:photos_attributes]["0"][:image]
  end

  def get_image_url
    if params[:size] and @photo.image.versions.keys.map(&:to_s).include? params[:size]
      params[:size].to_sym
    else
      :thumb
    end
  end

end
