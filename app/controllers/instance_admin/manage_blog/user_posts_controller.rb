class InstanceAdmin::ManageBlog::UserPostsController < InstanceAdmin::ManageBlog::BaseController
  before_filter :load_instance

  def index
    params[:filter] ||= 'all' # default filter
    @blog_posts = @instance.user_blog_posts.by_date
    @blog_posts = @blog_posts.highlighted if params[:filter] == 'highlighted'
    @blog_posts = @blog_posts.not_highlighted if params[:filter] == 'not_highlighted'
  end

  def edit
    @blog_post = @instance.user_blog_posts.find(params[:id])
  end

  def update
    @blog_post = @instance.user_blog_posts.find(params[:id])
    if @blog_post.update_attributes(post_params)
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_updated')
      redirect_to instance_admin_manage_blog_user_posts_path
    else
      render 'edit'
    end
  end

  def destroy
    @blog_post = @instance.user_blog_posts.find(params[:id])
    @blog_post.destroy
    flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_deleted')
    redirect_to instance_admin_manage_blog_user_posts_path
  end

  private

  def load_instance
    @instance = platform_context.instance
  end

  def post_params
    params.require(:user_blog_post).permit(secured_params.admin_user_blog_post)
  end
end
