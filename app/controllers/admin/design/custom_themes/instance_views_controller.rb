# frozen_string_literal: true
class Admin::Design::CustomThemes::InstanceViewsController < Admin::Design::BaseController
  include Admin::Versionable

  before_action :find_instance_view, only: [:edit, :update, :destroy]

  def index
    @instance_views = custom_theme.instance_views.custom_theme_views
  end

  def new
    @instance_view = custom_theme.instance_views.build
  end

  def edit
  end

  def create
    @instance_view = custom_theme.instance_views.build(instance_view_params)
    @instance_view.format = 'html'
    @instance_view.handler = 'liquid'
    @instance_view.view_type = InstanceView::CUSTOM_VIEW
    @instance_view.instance_id = current_instance.id
    if @instance_view.save
      flash[:success] = t 'flash_messages.instance_admin.manage.liquid_views.created'
      redirect_to action: :index
    else
      flash.now[:error] = @instance_view.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    if @instance_view.update_attributes(instance_view_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.liquid_views.updated'
      redirect_to action: :index
    else
      flash.now[:error] = @instance_view.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @instance_view.destroy
    flash[:success] = t('flash_messages.instance_admin.manage.liquid_views.deleted')
    redirect_to action: :index
  end

  private

  def custom_theme
    @custom_theme ||= CustomTheme.find(params[:theme_id])
  end

  def instance_view_params
    params.require(:instance_view).permit(secured_params.liquid_view)
  end

  def find_instance_view
    @instance_view ||= custom_theme.instance_views.custom_theme_views.find(params[:id])
  end
end
