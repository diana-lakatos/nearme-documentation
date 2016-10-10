class InstanceAdmin::Settings::SellerAttachmentsController < InstanceAdmin::Settings::BaseController
  def show
  end

  def update
    if @instance.update(seller_attachments_params)
      redirect_to({ action: :show }, flash: { success: t('flash_messages.instance_admin.settings.settings_updated') })
    else
      render :show, flash: { error: @instance.errors.full_messages.to_sentence }
    end
  end

  private

  def seller_attachments_params
    if params[:instance].key?(:seller_attachments_enabled) && params[:instance][:seller_attachments_enabled] == '0'
      params.require(:instance).permit(:seller_attachments_enabled)
    else
      params.require(:instance).permit(:seller_attachments_access_level)
    end
  end
end
