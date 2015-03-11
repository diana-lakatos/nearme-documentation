class InstanceAdmin::Manage::SearchController < InstanceAdmin::Manage::BaseController
  before_filter :find_instance

  def show
  end

  def update
    @instance.update_attributes(instance_params)
    if @instance.save
      flash[:success] = t('flash_messages.search.setting_saved')
      redirect_to instance_admin_manage_search_path
    else
      flash[:error] = @instance.errors.full_messages.to_sentence
      render :show
    end
  end

  private

  def find_instance
    @instance = platform_context.instance
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end
end
