class InstanceAdmin::SettingsController < InstanceAdmin::BaseController
  before_filter :find_instance


  def show
    @instance
  end

  def update
    params[:instance][:pricing_options] = {} if params[:instance][:pricing_options].blank?
    if @instance.update_attributes(params[:instance])
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated_successfully')
      redirect_to :action => :show
    else
      render :show
    end
  end

  private

  def find_instance
    @instance = platform_context.instance
  end

end
