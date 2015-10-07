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
    @blog_post = @blog_instance.blog_posts.find(params[:id])
  end

  def update
    @blog_post = @blog_instance.blog_posts.find(params[:id])
    if @blog_post.update_attributes(post_params)
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_updated')
      redirect_to instance_admin_manage_blog_posts_path
    else
      render 'edit'
    end
  end

  def delete_image
    case params[:image_type]
    when 'header'
      @blog_post = @blog_instance.blog_posts.find(params[:id])
      @blog_post.remove_header!
      @blog_post.save!
    when 'author_avatar'
      @blog_post = @blog_instance.blog_posts.find(params[:id])
      @blog_post.remove_author_avatar!
      @blog_post.save!
    end

    redirect_to :action => :edit
  end

  def destroy
    @blog_post = @blog_instance.blog_posts.find(params[:id])
    @blog_post.destroy
    flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_deleted')
    redirect_to instance_admin_manage_blog_posts_path
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
