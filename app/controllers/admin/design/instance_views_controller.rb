# frozen_string_literal: true
class Admin::Design::InstanceViewsController < Admin::Design::BaseController
  include Admin::Versionable

  before_action :find_instance_view, only: [:edit, :update, :destroy]

  def index
    @instance_views = platform_context.instance.instance_views.liquid_views
    @not_customized_instance_views_paths = InstanceView.not_customized_liquid_views_paths

    @instance_views_tree = build_views_tree(@instance_views)
    @not_customized_instance_views_paths_tree = build_paths_tree(@not_customized_instance_views_paths)
  end

  def new
    opts = {
      path: params[:path],
      partial: true
    }
    if params[:instance_view_id].present?
      instance_view = InstanceView.find(params[:instance_view_id])
      opts = {
        path: instance_view.path,
        partial: instance_view.partial,
        body: instance_view.body
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
    @instance_view = platform_context.instance.instance_views.build opts
  end

  def edit
  end

  def create
    @instance_view = platform_context.instance.instance_views.build(instance_view_params)
    @instance_view.format = 'html'
    @instance_view.handler = 'liquid'
    @instance_view.view_type = InstanceView::VIEW_VIEW
    if @instance_view.save
      flash[:success] = t 'admin.flash_messages.manage.liquid_views.created'
      redirect_to [:edit, :admin, :design, @instance_view]
    else
      flash.now[:error] = @instance_view.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    # do not allow to change path for now
    params[:instance_view][:path] = @instance_view.path
    if @instance_view.update_attributes(instance_view_params)
      flash[:success] = t 'admin.flash_messages.manage.liquid_views.updated'
      redirect_to [:edit, :admin, :design, @instance_view]
    else
      flash.now[:error] = @instance_view.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @instance_view.destroy
    flash[:success] = t 'admin.flash_messages.manage.liquid_views.deleted'
    redirect_to action: :index
  end

  private

  def instance_view_params
    params.require(:instance_view).permit(secured_params.liquid_view)
  end

  def find_instance_view
    @instance_view ||= platform_context.instance.instance_views.liquid_views.find(params[:id])
  end

  def build_views_tree(instance_views)
    tree = {}

    instance_views.each do |iv|
      memo = ''
      iv.path.split('/').each do |part|
        memo = memo != '' ? "#{memo}/#{part}" : part
        tree[memo] ||= []
      end
      tree[iv.path] << iv
    end

    tree
  end

  def build_paths_tree(paths)
    tree = {}

    paths.each do |path|
      memo = ''
      path.split('/').each do |part|
        memo = memo != '' ? "#{memo}/#{part}" : part
        tree[memo] ||= nil
      end
      tree[path] = path
    end

    tree
  end
end
