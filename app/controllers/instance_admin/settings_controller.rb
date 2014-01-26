class InstanceAdmin::SettingsController < InstanceAdmin::BaseController
  before_filter :find_instance

  def show
    @instance
  end

  def update
    @instance.password_protected = !params[:instance][:password_protected].to_i.zero?
    params[:instance][:marketplace_password] = '' if !@instance.password_protected
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

end
