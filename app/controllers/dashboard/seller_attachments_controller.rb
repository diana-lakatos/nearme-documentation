class Dashboard::SellerAttachmentsController < Dashboard::AssetsController

  before_action :get_file, only: :create

  def create
    attachment = SellerAttachment.new
    attachment.assetable = @listing
    attachment.user = current_user
    attachment.data = @file
    attachment.set_initial_access_level
    if attachment.save
      render partial: 'new_attachment', locals: { attachment: attachment }
    else
      render partial: 'errors', locals: { errors: attachment.errors.full_messages.join(', ') }
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
    attachment = @platform_context.instance.seller_attachments.find(params[:id])
    attachment.destroy
    render text: "$('li[data-seller-attachment=#{attachment.id}]').remove();"
  end

  private

  def seller_attachments_params
    params.require(:seller_attachment).permit(secured_params.seller_attachment(@platform_context.instance))
  end

  def get_file
    @file = if @listing_params
        @listing_params[:attachments_attributes]['0'][:data]
      elsif params.has_key?(:boarding_form)
        params[:boarding_form][:product_form][:attachments_attributes]['0']['data']
      else
        params[:product_form][:attachments_attributes]['0']['data']
      end
  end

end
