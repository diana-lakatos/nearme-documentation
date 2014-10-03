class InstanceAdmin::Settings::ConfigurationController < InstanceAdmin::Settings::BaseController
  skip_before_filter :check_if_locked, only: :lock

  def lock
    if @instance.update_attributes(instance_params)
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      redirect_to action: :show
    else
      flash[:error] = @instance.errors.full_messages.to_sentence
      redirect_to action: :show
    end
  end
end
