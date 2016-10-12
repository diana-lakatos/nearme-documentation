class InstanceAdmin::Settings::TranslationsController < InstanceAdmin::Settings::BaseController
  def show
    flash[:success] = t 'flash_messages.instance_admin.settings.locales.keys_updated'
    redirect_to instance_admin_settings_locales_path
  end

  def update
    if params[:instance].present?
      if @instance.update_attributes(instance_params)
        flash.now[:success] = t('flash_messages.instance_admin.settings.settings_updated')
        find_or_build_billing_gateway_for_usd
        redirect_to instance_admin_settings_locales_path
      else
        flash[:error] = @instance.errors.full_messages.to_sentence
        redirect_to instance_admin_settings_locales_path
      end
    else
      redirect_to instance_admin_settings_locales_path
    end
  rescue ActiveRecord::RecordNotUnique
    flash[:error] = t('general.unexpected_error_occurred')
    redirect_to instance_admin_settings_locales_path
  end
end
