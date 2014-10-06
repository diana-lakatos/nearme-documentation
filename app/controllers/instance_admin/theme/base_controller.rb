class InstanceAdmin::Theme::BaseController < InstanceAdmin::ResourceController
  before_filter :find_theme

  def index
    redirect_to instance_admin_theme_info_path
  end

  private

  def find_theme
    @theme = platform_context.theme
  end

  def theme_params
    params.require(:theme).permit(secured_params.theme)
  end
end
