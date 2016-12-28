# frozen_string_literal: true
class Admin::Design::BaseController < Admin::BaseController
  layout 'admin/config'

  # before_filter :find_theme

  def index
    redirect_to admin_design_themes_path
  end

  # private

  # def find_theme
  #   @theme = platform_context.theme
  # end

  # def theme_params
  #   params.require(:theme).permit(secured_params.theme)
  # end
end
