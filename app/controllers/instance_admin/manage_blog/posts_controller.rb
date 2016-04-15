class InstanceAdmin::ManageBlog::PostsController < InstanceAdmin::ManageBlog::BaseController
  before_filter :load_instance

  before_filter :set_breadcrumbs
  before_filter :redirect_to_index_if_no_blog_instance, except: :index

  def index
    @blog_posts = @blog_instance.try(:blog_posts).try(:by_date) || []
  end

  def new
    @blog_post = @blog_instance.blog_posts.build(published_at: Time.zone.now)
  end

  def create
    @blog_post = @blog_instance.blog_posts.build(post_params)
    @blog_post.user = current_user
    if @blog_post.save
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_added')
      redirect_to instance_admin_manage_blog_posts_path
    else
      render :new
    end
  end

  def edit
    respond_with resource
  end

  def update
    if resource.update_attributes(post_params)
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_updated')
      redirect_to instance_admin_manage_blog_posts_path
    else
      render 'edit'
    end
  end

  def delete_image
    case params[:image_type]
    when 'header'
      resource.remove_header!
    when 'author_avatar'
      resource.remove_author_avatar!
    end
    resource.save!

    redirect_to action: :edit
  end

  def destroy
    resource.destroy
    flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_deleted')
    redirect_to instance_admin_manage_blog_posts_path
  end

  protected

  def resource
    @blog_post ||= @blog_instance.blog_posts.find(params[:id])
  end

  private

  def load_instance
    @instance = platform_context.instance
  end

  def post_params
    params.require(:blog_post).permit(secured_params.blog_post)
  end

  def set_breadcrumbs
    @breadcrumbs_title = 'Manage Blog'
  end

  def redirect_to_index_if_no_blog_instance
    unless @blog_instance.present?
      flash[:error] = 'Blog has not been set up.'
      redirect_to instance_admin_manage_blog_posts_path
    end
  end
end
