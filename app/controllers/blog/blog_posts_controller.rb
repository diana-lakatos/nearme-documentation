class Blog::BlogPostsController < Blog::ApplicationController

  def index
    @blog_posts = @blog_instance.blog_posts.paginate(:page => params[:page], :per_page => 10)
  end

  def show
    @blog_post = @blog_instance.blog_posts.find(params[:id])
  end

end
