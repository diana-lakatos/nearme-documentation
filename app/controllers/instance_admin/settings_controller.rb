class InstanceAdmin::SettingsController < InstanceAdmin::BaseController
  before_filter :find_instance, :find_instance_translations

  def show
    @instance
  end

  def update
    if @instance.update_attributes(params[:instance])
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      render :show
    else
      render :show
    end
  end

  private

  def find_instance
    @instance = platform_context.instance
  end

  def find_instance_translations
    @translations = @instance.translations
  end

end
