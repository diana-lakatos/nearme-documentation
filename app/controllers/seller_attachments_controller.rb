class SellerAttachmentsController < ApplicationController

  def index
    if !current_instance.seller_attachments_enabled?
      render nothing: true, status: :bad_request
    elsif params[:seller_attachable_type].blank? || params[:seller_attachable_id].blank?
      render nothing: true, status: :bad_request
    else
      get_seller_attachable
      @attachments = @seller_attachable.attachments_for_user(current_user)
      tab_content = render_to_string(template: 'seller_attachments/index', formats: [:html], layout: false)
      tab_header = render_to_string(partial: 'seller_attachments/tab_header', formats: [:html])
      render json: { tab_content: tab_content, tab_header: tab_header }
    end
  end

  def show
    attachment = SellerAttachment.find(params[:id])
    if attachment.accessible_to?(current_user)
      # send_file(attachment.data.path, type: attachment.data_content_type, disposition: 'attachment', status: 200)
      redirect_to attachment.url_content
    else
      redirect_to root_url
    end
  end

  private

  def get_seller_attachable
    @seller_attachable =
      case params[:seller_attachable_type]
      when 'Transactable' then Transactable
      end.with_deleted.find(params[:seller_attachable_id])
  end

end
