# frozen_string_literal: true
module Api
  class V4::User::CustomImagesController < Api::V4::User::BaseController
    def destroy
      custom_attachment = current_user.custom_images.find(params[:id])
      custom_attachment.destroy
      render nothing: true
    end
  end
end
