class SellerAttachmentsController < ApplicationController

  def show
    attachment = SellerAttachment.find(params[:id])
    if attachment.accessible_to?(current_user)
      # send_file(attachment.data.path, type: attachment.data_content_type, disposition: 'attachment', status: 200)
      redirect_to attachment.url_content
    else
      redirect_to root_url
    end
  end

end
