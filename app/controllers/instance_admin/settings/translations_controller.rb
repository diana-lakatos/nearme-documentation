class InstanceAdmin::Settings::TranslationsController < InstanceAdmin::Settings::BaseController

  def show
    flash[:success] = t 'flash_messages.instance_admin.settings.locales.keys_updated'
    redirect_to instance_admin_settings_locales_path
  end

  def update
    super
  # This avoids errors that have occurred in the past like when
  # the user updated the same translation key from two separate windows
  # the second edit failing because of missing id in params which
  # triggered a uniqueness constraint violation
  rescue ActiveRecord::RecordNotUnique => e
    flash[:error] = t('general.unexpected_error_occurred')
    redirect_to instance_admin_settings_locales_path
  end

end
