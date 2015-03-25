class InstanceAdmin::Theme::HomepageController < InstanceAdmin::Theme::BaseController
  include InstanceAdmin::Versionable
  set_resource_method { @theme }

  def show
  end

  def update
    if @theme.update_attributes(theme_params)
      flash[:success] = t('flash_messages.instance_admin.theme.theme_updated_successfully')
      redirect_to :action => :show
    else
      flash[:error] = @theme.errors.full_messages.to_sentence
      render :show
    end
  end
end
