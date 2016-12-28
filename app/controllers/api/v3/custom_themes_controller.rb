module Api
  class V3::CustomThemesController < BaseController
    before_action :find_custom_theme, except: [:index]

    def index
      @classic_theme_active = CustomTheme.where(in_use: true).count.zero?
      @custom_themes = CustomTheme.all
    end

    def create
      @custom_theme = current_instance.custom_themes.build(custom_theme_params)

      if @custom_theme.save
        render_api_object(@custom_theme, meta: {
                            redirect: edit_admin_design_theme_path(@custom_theme)
                          })
      else
        render_api_errors(@custom_theme.errors)
      end
    end

    def update
      if @custom_theme.update(custom_theme_params)
        render_api_object(@custom_theme, meta: {
                            message: t('admin.themes.flash.updated')
                          })
      else
        render_api_errors(@custom_theme.errors)
      end
    end

    def delete
      @custom_theme.destroy
      render :nothing, status: 204
    end

    private

    def custom_theme_params
      params.require(:custom_theme).permit(secured_params.custom_theme)
    end

    def find_custom_theme
      @custom_theme ||= CustomTheme.find(params[:id])
    end
  end
end
