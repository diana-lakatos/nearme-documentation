class Dashboard::SellerAttachmentsController < Dashboard::AssetsController
  before_action :get_file, only: :create

  def new
    @listing = current_user.transactables.find_by(id: params[:transactable_id]) || current_user.approved_transactables_collaborated.find_by(id: params[:transactable_id])
    @attachment = SellerAttachment.new
  end

  def create
    attachment = SellerAttachment.new
    attachment.assetable = @listing
    attachment.user = current_user
    attachment.title = @title
    attachment.data = @file
    attachment.set_initial_access_level
    if request.xhr?
      if attachment.save
        render partial: 'dashboard/shared/attachments/seller_attachment', locals: { attachment: attachment }
      else
        render partial: 'errors', locals: { errors: attachment.errors.full_messages.join(', ') }
      end
    else
      if attachment.save
        flash[:notice] = t('flash_messages.dashboard.seller_attachments.created')
      else
        flash[:error] = t('flash_messages.dashboard.seller_attachments.not_created') + "\n" + attachment.errors.full_messages.join("\n")
      end
      redirect_to params[:path].presence || root_path
    end
  end

  def update
    if @platform_context.instance.seller_attachments_enabled?
      attachment = current_user.attachments.find(params[:id])
      attachment.update_attributes(seller_attachments_params)
    end
    render nothing: true, status: 200
  end

  def destroy
    attachment = SellerAttachment.find(params[:id])
    if [attachment.user_id, attachment.assetable.try(:creator_id)].compact.include?(current_user.id)
      attachment.destroy
      if request.xhr?
        render text: "$('li[data-attachment=#{attachment.id}]').remove();"
      else
        redirect_to(request.referer.presence || root_path) + "#transactable_#{attachment.assetable_id}"
      end
    else
      render nothing: true, status: 401
    end
  end

  private

  def seller_attachments_params
    params.require(:seller_attachment).permit(secured_params.seller_attachment(@platform_context.instance))
  end

  def get_file
    @file = @listing_params[:attachments_attributes]['0'][:data]
    @title = @listing_params[:attachments_attributes]['0'][:title]
  end
end
