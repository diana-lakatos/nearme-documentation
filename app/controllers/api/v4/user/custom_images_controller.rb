# frozen_string_literal: true
module Api
  class V4::User::CustomImagesController < Api::V4::User::BaseController
    def destroy
      DestroyResource.new(resource: current_user.custom_images.find(params[:id]),
                          params: params,
                          current_user: current_user).call
      render nothing: true
    end
  end
end
