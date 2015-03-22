class InstanceAdmin::Settings::TranslationsController < InstanceAdmin::Settings::BaseController

  def show
    flash[:success] = t 'flash_messages.instance_admin.settings.locales.keys_updated'
    redirect_to instance_admin_settings_locales_path
  end
end
