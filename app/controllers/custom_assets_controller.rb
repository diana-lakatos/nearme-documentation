class CustomAssetsController < ApplicationController
  def show
    attachment = Ckeditor::Asset.find(params[:id])
    if attachment.accessible_to?(current_user)
      redirect_to attachment.url_content
    else
      redirect_to root_url
    end
  end
end
