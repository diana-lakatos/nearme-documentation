class InstanceAdmin::ThemeController < InstanceAdmin::BaseController
  before_filter :find_theme

  def show
  end

  def update
    if @theme.update_attributes(params[:theme])
      flash[:success] = t('flash_messages.instance_admin.theme.theme_updated_successfully')
      redirect_to :action => :show
    else
      render :show
    end
  end

  private

  def find_theme
    @theme = platform_context.theme
  end

end
