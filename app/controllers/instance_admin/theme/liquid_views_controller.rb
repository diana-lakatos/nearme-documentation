class InstanceAdmin::Theme::LiquidViewsController < InstanceAdmin::Theme::BaseController
  include InstanceAdmin::Versionable
  actions :all, :except => [ :show ]

  before_filter :find_transactable_type, only: [:create, :update]
  before_filter :find_liquid_view, only: [:edit, :update, :destroy]
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
    if params[:path] && @base_view = InstanceView::DEFAULT_LIQUID_VIEWS_PATHS[params[:path]]
      view_file = DbViewResolver.virtual_path(params[:path].dup, @base_view.fetch(:is_partial, true))
      view_paths.each do |view_path|
        if path = view_path.try(:to_path)
          if File.exists?(File.join(path, "#{view_file}.html.liquid"))
            opts[:body] = File.read(File.join(path, "#{view_file}.html.liquid"))
            break
          end
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
    @liquid_view.transactable_type = @transactable_type
    @liquid_view.view_type = InstanceView::VIEW_VIEW
    if @liquid_view.save
      flash[:success] = t 'flash_messages.instance_admin.manage.liquid_views.created'
      redirect_to action: :index
    else
      flash.now[:error] = @liquid_view.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    # do not allow to change path for now
    params[:liquid_view][:path] = @liquid_view.path
    if @liquid_view.update_attributes(template_params.merge(transactable_type_id: @transactable_type.try(:id)))
      flash[:success] = t 'flash_messages.instance_admin.manage.liquid_views.updated'
      redirect_to action: :index
    else
      flash.now[:error] = @liquid_view.errors.full_messages.to_sentence
      render :edit
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

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:liquid_view][:transactable_type_id]) if params[:liquid_view][:transactable_type_id].present? rescue nil
  end

  def find_liquid_view
    @liquid_view ||= platform_context.instance.instance_views.liquid_views.find(params[:id])
  end

end

