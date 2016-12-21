# frozen_string_literal: true
class Dashboard::CustomImagesController < Dashboard::BaseController
  before_action :find_custom_image

  def edit
  end

  def update
    @custom_image.image_transformation_data = { crop: params[:crop], rotate: params[:rotate] }
    unless @custom_image.save
      render :edit
    end
  end

  def destroy
    if @custom_image.destroy
      render text: { success: true, id: @custom_image.id }, content_type: 'text/plain'
    else
      render text: { errors: @custom_image.errors.full_messages }, status: 422, content_type: 'text/plain'
    end
  end

  private

  def find_custom_image
    @custom_image = current_user.custom_images.find(params[:id])
  end
end
