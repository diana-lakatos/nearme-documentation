class InstanceAdmin::CustomTemplates::CustomThemesController < InstanceAdmin::CustomTemplates::BaseController
  include InstanceAdmin::Versionable
  actions :all, :except => [ :show ]

  def index
    @custom_themes = CustomTheme.all
  end

  def create
    @custom_theme = current_instance.custom_themes.build(custom_theme_params)
    create! do |format|
      format.html do
        redirect_to action: 'index'
      end
      format.json do
        render nothing: true
      end
    end
  end

  def update
    update! do |format|
      format.html do
        redirect_to action: 'index'
      end
      format.json do
        render nothing: true
      end
    end
  end

  private

  def custom_theme_params
    params.require(:custom_theme).permit(secured_params.custom_theme)
  end

end

