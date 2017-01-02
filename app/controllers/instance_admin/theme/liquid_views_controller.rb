# frozen_string_literal: true
class InstanceAdmin::Theme::LiquidViewsController < InstanceAdmin::Theme::BaseController
  include InstanceAdmin::Versionable
  actions :all, except: [:show]

  before_action :find_liquid_view, only: [:edit, :update, :destroy]
  set_resource_method :find_liquid_view

  def index
    @liquid_views = platform_context.instance.instance_views.liquid_views
    @not_customized_liquid_views_paths = InstanceView.not_customized_liquid_views_paths
  end

  def new
    opts = {
      path: params[:path],
      partial: true
    }
    if params[:liquid_view_id].present?
      liquid_view = InstanceView.find(params[:liquid_view_id])
      opts = {
        path: liquid_view.path,
        partial: liquid_view.partial,
        body: liquid_view.body
      }
    elsif params[:path] && @base_view = InstanceView::DEFAULT_LIQUID_VIEWS_PATHS[params[:path]]
      view_file = DbViewResolver.virtual_path(params[:path].dup, @base_view.fetch(:is_partial, true))
      view_paths.each do |view_path|
        next unless path = view_path.try(:to_path)
        if File.exist?(File.join(path, "#{view_file}.html.liquid"))
          opts[:body] = File.read(File.join(path, "#{view_file}.html.liquid"))
          break
        end
      end
      opts[:partial] = @base_view.fetch(:is_partial, true)
    end
    @liquid_view = platform_context.instance.instance_views.build opts
  end

  def edit
  end

  def create
    @liquid_view = platform_context.instance.instance_views.build(template_params)
    @liquid_view.format = 'html'
    @liquid_view.handler = 'liquid'
    @liquid_view.view_type = InstanceView::VIEW_VIEW
    if @liquid_view.save
      if request.xhr?
        render json: { status: 'success', data: { message: t('flash_messages.instance_admin.manage.liquid_views.created') } }
      else
        flash[:success] = t 'flash_messages.instance_admin.manage.liquid_views.created'
        redirect_to edit_admin_theme_liquid_view_path(@liquid_view)
      end
    else
      if request.xhr?
        render json: { status: 'fail', data: @liquid_view.errors.full_messages }
      else
        flash.now[:error] = @liquid_view.errors.full_messages.to_sentence
        render action: :new
      end
    end
  end

  def update
    # do not allow to change path for now
    params[:liquid_view][:path] = @liquid_view.path
    if @liquid_view.update_attributes(template_params)
      if request.xhr?
        render json: { status: 'success' }
      else
        flash[:success] = t 'flash_messages.instance_admin.manage.liquid_views.updated'
        redirect_to edit_instance_admin_theme_liquid_view_path(@liquid_view)
      end
    else
      if request.xhr?
        render json: { status: 'fail', data: { errors: @liquid_view.errors.full_messages } }
      else
        flash.now[:error] = @liquid_view.errors.full_messages.to_sentence
        render :edit
      end
    end
  end

  def destroy
    @liquid_view.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.liquid_views.deleted'
    redirect_to action: :index
  end

  private

  def template_params
    params.require(:liquid_view).permit(secured_params.liquid_view)
  end

  def find_liquid_view
    @liquid_view ||= platform_context.instance.instance_views.liquid_views.find(params[:id])
  end
end
