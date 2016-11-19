# frozen_string_literal: true
class Dashboard::PhotosController < Dashboard::AssetsController
  before_action :get_image, only: :create

  def create
    @photo = Photo.new
    @photo.owner = @owner
    @photo.owner_type ||= @owner_type
    @photo.image = @image
    @photo.creator_id = current_user.id
    if @photo.save

      sizes = {}
      @photo.image.thumbnail_dimensions.each_with_index do |dimensions, _index|
        sizes[dimensions[0]] = { width: dimensions[1][:width], height: dimensions[1][:height], url: @photo.image.url(dimensions[0].to_sym) }
      end

      sizes[:full] = { url: @photo.image.url }

      render text: {
        id: @photo.id,
        transactable_id: @photo.owner_id,
        thumbnail_dimensions: @photo.image.thumbnail_dimensions[:medium],
        url: @photo.image.url(:medium),
        destroy_url: destroy_space_wizard_photo_path(@photo),
        resize_url: edit_dashboard_photo_path(@photo),
        sizes: sizes
      }.to_json,
             content_type: 'text/plain'
    else
      render text: [{ error: @photo.errors.full_messages }], content_type: 'text/plain', status: 422
    end
  end

  def edit
    @photo = current_user.photos.find(params[:id])
    if request.xhr?
      render partial: 'dashboard/photos/resize_form', locals: { form_url: dashboard_photo_path(@photo), object: @photo.image, object_url: @photo.original_image_url }
    end
  end

  def update
    @photo = current_user.photos.find(params[:id])
    @photo.image_transformation_data = { crop: params[:crop], rotate: params[:rotate] }
    if @photo.save
      render partial: 'dashboard/photos/resize_succeeded'
    else
      render partial: 'dashboard/photos/resize_form', locals: { form_url: dashboard_photo_path(@photo), object: @photo.image, object_url: @photo.original_image_url }
    end
  end

  def destroy
    @photo = current_user.photos.find(params[:id])
    if @photo.destroy
      render text: { success: true, id: @photo.id }, content_type: 'text/plain'
    else
      render text: { errors: @photo.errors.full_messages }, status: 422, content_type: 'text/plain'
    end
  end

  private

  def get_image
    @image = @listing_params[:photos_attributes]['0'][:image]
  end
end
