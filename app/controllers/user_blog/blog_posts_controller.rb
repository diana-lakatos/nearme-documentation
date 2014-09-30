class UserBlog::BlogPostsController < UserBlog::BaseController

  def new
    @user_blog_post = current_user.blog_posts.new
    @user_blog_post.author_name = current_user.name
    @user_blog_post.author_biography = current_user.biography
  end

  def create
    @user_blog_post = current_user.blog_posts.build(user_blog_post_params)
    if @user_blog_post.save
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_added')
      redirect_to user_blog_path
    else
      @user_blog_post = @user_blog_post
      render :new
    end
  end

  def edit
    @user_blog_post = current_user.blog_posts.find(params[:id])
  end

  def update
    @user_blog_post = current_user.blog_posts.find(params[:id])
    if @user_blog_post.update_attributes(user_blog_post_params)
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_updated')
      redirect_to user_blog_path
    else
      @user_blog_post = @user_blog_post
      render :edit
    end
  end

  def destroy
    user_blog_post = current_user.blog_posts.find(params[:id])
    user_blog_post.destroy
    flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_deleted')
    redirect_to user_blog_path
  end

  private

  def user_blog_post_params
    params.require(:user_blog_post).permit(secured_params.user_blog_post)
  end
end
