class InstanceAdmin::Theme::VersionsController < InstanceAdmin::Theme::BaseController
  before_filter :set_parent
  before_filter :set_params, only: :rollback

  def index
  end

  def rollback
    if @parent.update_attributes resource.reify.serializable_hash(only: @fields)
      redirect_to @redirect_url, notice: "Page has been successfully restored to previous version"
    else
      flash[:error] = "Unable to restore page to previus version"
      render :show
    end
  end

  private

  def set_params
    case @parent
    when Page
      @fields = %w(path content css_content)
      @redirect_url = edit_instance_admin_theme_page_path(@parent)
    when Theme
      @fields = %w(homepage_content homepage_css)
      @redirect_url = instance_admin_theme_homepage_path
    when InstanceView
      @fields = %w(body)
      @redirect_url = polymorphic_url([:instance_admin, :theme, @parent_resource])
    end
  end

  def set_parent
    @parent_resource = params[:parent_resource]
    @parent = case @parent_resource
              when 'pages'
                Page.friendly.find params[:page_id]
              when 'homepage'
                Theme.first
              when 'homepage_template'
                platform_context.instance.instance_views.find_by_path 'home/index'
              when 'footer'
                platform_context.instance.instance_views.find_by_path 'layouts/theme_footer'
              when 'header'
                platform_context.instance.instance_views.find_by_path 'layouts/theme_header'
              end
  end

  def collection
    @versions ||= @parent.versions
  end

  def resource
    @resource ||= @parent.versions.find(params[:id])
  end

end
