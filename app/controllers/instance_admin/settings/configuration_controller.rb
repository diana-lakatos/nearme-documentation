class InstanceAdmin::Settings::ConfigurationController < InstanceAdmin::Settings::BaseController
  skip_before_filter :check_if_locked, only: :lock

  def update
    validate_imap_settings if params[:validate_imap_settings_button]
    super
  end

  def lock
    if @instance.update_attributes(instance_params)
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      redirect_to action: :show
    else
      flash[:error] = @instance.errors.full_messages.to_sentence
      redirect_to action: :show
    end
  end

  protected

  def validate_imap_settings
    isv = ImapSettingsValidator.new(PlatformContext.current.instance)
    if isv.validate_settings
      flash[:success] = t('flash_messages.instance_admin.imap_settings.validation_successful')
    else
      flash[:error] = t('flash_messages.instance_admin.imap_settings.could_not_validate')
    end
  end
end
