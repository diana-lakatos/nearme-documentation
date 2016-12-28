# frozen_string_literal: true
class Admin::Design::CustomThemesController < Admin::Design::BaseController
  include Admin::Versionable

  before_action :find_custom_theme, only: [:edit, :update, :destroy]

  def index
    @classic_theme_active = CustomTheme.where(in_use: true).count.zero?
    @custom_themes = CustomTheme.all
  end

  def new
    @custom_theme = current_instance.custom_themes.build
  end

  def create
    @custom_theme = current_instance.custom_themes.build(custom_theme_params)

    if @custom_theme.save
      flash[:success] = t('admin.themes.flash.created')
      redirect_to edit_admin_design_theme_path(@custom_theme)
    else
      flash.now[:error] = @custom_theme.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    if @custom_theme.update(custom_theme_params)
      flash[:success] = t('admin.themes.flash.updated')
      redirect_to edit_admin_design_theme_path(@custom_theme)
    else
      flash.now[:error] = @custom_theme.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @custom_theme.destroy
    flash[:success] = t 'admin.themes.flash.destroyed'
    redirect_to action: :index
  end

  private

  def custom_theme_params
    params.require(:custom_theme).permit(secured_params.custom_theme)
  end

  def find_custom_theme
    @custom_theme ||= CustomTheme.find(params[:id])
  end
end
