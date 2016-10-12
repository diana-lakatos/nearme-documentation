class InstanceAdmin::CustomTemplates::CustomThemes::InstanceViewsController < InstanceAdmin::CustomTemplates::BaseController
  include InstanceAdmin::Versionable
  actions :all, except: [:show]

  before_filter :find_liquid_view, only: [:edit, :update, :destroy]
  set_resource_method :find_liquid_view

  def index
    @liquid_views = custom_theme.instance_views.custom_theme_views
  end

  def new
    @liquid_view = custom_theme.instance_views.build
  end

  def edit
  end

  def create
    @liquid_view = custom_theme.instance_views.build(template_params)
    @liquid_view.format = 'html'
    @liquid_view.handler = 'liquid'
    @liquid_view.view_type = InstanceView::CUSTOM_VIEW
    @liquid_view.instance_id = current_instance.id
    if @liquid_view.save
      flash[:success] = t 'flash_messages.instance_admin.manage.liquid_views.created'
      redirect_to action: :index
    else
      flash.now[:error] = @liquid_view.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    if @liquid_view.update_attributes(template_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.liquid_views.updated'
      redirect_to action: :index
    else
      flash.now[:error] = @liquid_view.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @liquid_view.destroy
    flash[:success] = t('flash_messages.instance_admin.manage.liquid_views.deleted')
    redirect_to action: :index
  end

  private

  def custom_theme
    @custom_theme ||= CustomTheme.find(params[:custom_theme_id])
  end

  def template_params
    params.require(:liquid_view).permit(secured_params.liquid_view)
  end

  def find_liquid_view
    @liquid_view ||= custom_theme.instance_views.custom_theme_views.find(params[:id])
  end
end
