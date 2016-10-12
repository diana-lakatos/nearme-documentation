class InstanceAdmin::Theme::InfoController < InstanceAdmin::Theme::BaseController
  def show
    @theme.theme_font || @theme.build_theme_font
  end

  def update
    theme_update_service = ThemeUpdateService.new(@theme)
    if theme_update_service.update(theme_params)
      flash[:success] = t('flash_messages.instance_admin.theme.theme_updated_successfully')
      redirect_to action: :show
    else
      flash[:error] = @theme.errors.full_messages.to_sentence
      render :show
    end
  end
end
