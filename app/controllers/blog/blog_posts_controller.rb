class Blog::BlogPostsController < Blog::ApplicationController

  before_filter :redirect_if_disabled
  before_filter :find_post, :only => [:show]

  def index
    @blog_posts = @blog_instance.blog_posts.published.by_date.paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  private

  def find_post
    @blog_post = @blog_instance.blog_posts.find(params[:id])
    # a 301 redirect that uses the current friendly id.
    if request.path != blog_post_path(@blog_post)
      return redirect_to @blog_post, :status => :moved_permanently
    end
  end

  def redirect_if_disabled
    return if @blog_instance.enabled?
    flash[:notice] = 'This blog is currently inactive.'
    redirect_to root_path
  end

end
