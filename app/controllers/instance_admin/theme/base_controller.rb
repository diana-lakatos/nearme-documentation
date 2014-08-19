class InstanceAdmin::Theme::BaseController < InstanceAdmin::ResourceController
  CONTROLLERS = { 'info'     => { default_action: 'show' },
                  'design'   => { default_action: 'show' },
                  'homepage template' => { controller: '/instance_admin/theme/homepage_template', default_action: 'show' },
                  'homepage content' => { controller: '/instance_admin/theme/homepage', default_action: 'show' },
                  'pages'    => { default_action: 'index' }}

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
