class Manage::PhotosController < Manage::BaseController

  before_filter :get_proper_hash, :only => [:create]

  def create
    @photo = Photo.new
    @photo.image_original_url = @image_url
    @photo.content = @content
    @photo.content_type = @content_type
    @photo.content_id = @content_id
    @photo.creator_id = current_user.id
    if @photo.save
      render :text => {
        :id => @photo.id, 
        :content_id => @photo.content_id,
        :thumbnail_dimensions => @photo.image.thumbnail_dimensions[:medium],
        :url => @photo.image_url(:medium),
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
      render partial: 'resize_form', :locals => { :form_url => manage_photo_path(@photo), :object => @photo.image, :object_url => @photo.image_url }
    end
  end

  def update
    @photo = current_user.photos.find(params[:id])
    @photo.image_transformation_data = { :crop => params[:crop], :rotate => params[:rotate] }
    if @photo.save
      render partial: 'manage/photos/resize_succeeded'
    else
      render partial: 'resize_form', :locals => { :form_url => manage_photo_path(@photo), :object => @photo.image, :object_url => @photo.image_url }
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
      @content_id = @param[:id]
      @content = nil
    # we came from dashboard
    else 
      Photo::AVAILABLE_CONTENT.each do |content|
        @param = params[content.downcase.to_sym]
        if @param
          @content_type = content
          @content_id = @param[:id]
          @content = @param[:id].present? ? current_user.send(content.pluralize.downcase.to_sym).find(@param[:id]) : nil
          break
        end
      end
      raise 'Unknown path to photos_attributes' unless @content_type
    end
    @image_url = @param[:photos_attributes]["0"][:image]
  end

end
