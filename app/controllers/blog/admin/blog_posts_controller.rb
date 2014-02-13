class Blog::Admin::BlogPostsController < Blog::Admin::ApplicationController

  def index
    @blog_posts = @blog_instance.blog_posts.by_date
  end

  def new
    @blog_post = @blog_instance.blog_posts.build(published_at: Time.zone.now)
  end

  def create
    @blog_post = @blog_instance.blog_posts.build(params[:blog_post])
    @blog_post.user = current_user
    if @blog_post.save
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_added')
      redirect_to blog_admin_blog_posts_path
    else
      render :new
    end
  end

  def edit
    @blog_post = @blog_instance.blog_posts.find(params[:id])
  end

  def update
    @blog_post = @blog_instance.blog_posts.find(params[:id])
    if @blog_post.update_attributes(params[:blog_post])
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_updated')
      redirect_to blog_admin_blog_posts_path
    else
      render 'edit'
    end
  end

  def destroy
    @blog_post = @blog_instance.blog_posts.find(params[:id])
    @blog_post.destroy
    flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_deleted')
    redirect_to blog_admin_blog_posts_path
  end

end
