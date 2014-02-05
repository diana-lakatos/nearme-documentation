class Blog::BlogPostsController < Blog::ApplicationController

  before_filter :redirect_if_disabled

  def index
    @blog_posts = @blog_instance.blog_posts.where("published_at < ? OR published_at IS NULL", Time.zone.now)
    @blog_posts = @blog_posts.order('COALESCE(published_at, created_at) desc')
    @blog_posts = @blog_posts.paginate(:page => params[:page], :per_page => 10)
  end

  def show
    @blog_post = @blog_instance.blog_posts.find(params[:id])
  end

  private

  def redirect_if_disabled
    return if @blog_instance.enabled?
    flash[:notice] = 'This blog is currently inactive.'
    redirect_to root_path
  end

end
