class Dashboard::UserBlog::BlogPostsController < Dashboard::UserBlog::BaseController

  before_filter :find_user_blog_post, only: [:edit, :update, :destroy, :delete_image]

  def index
    redirect_to dashboard_blog_path
  end

  def new
    @blog_post = current_user.blog_posts.new author_name: current_user.name, author_biography: current_user.properties.try(:biography),
                                             published_at: Time.zone.now.to_date
  end

  def create
    params[:user_blog_post][:published_at] = date_time_handler.convert_to_datetime(params[:user_blog_post][:published_at]) if params[:user_blog_post][:published_at] if params[:user_blog_post]
    @blog_post = current_user.blog_posts.build(user_blog_post_params)
    if @blog_post.save
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_added')
      redirect_to dashboard_blog_path
    else
      render :new
    end
  end

  def edit
    @blog_post.published_at = @blog_post.published_at.to_date
  end

  def update
    if @blog_post.update_attributes(user_blog_post_params)
      flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_updated')
      redirect_to dashboard_blog_path
    else
      render :edit
    end
  end

  def destroy
    @blog_post.destroy
    flash[:success] = t('flash_messages.blog_admin.blog_posts.blog_post_deleted')
    redirect_to dashboard_blog_path
  end

  def delete_image
    # We avoid interpolation because easy to go wrong and add security vulnerabilities
    case params[:image_type]
    when 'hero_image'
      @blog_post.remove_hero_image!
      @blog_post.save!
    when 'author_avatar_img'
      @blog_post.remove_author_avatar_img!
      @blog_post.save!
    end

    redirect_to edit_dashboard_blog_post_path(@blog_post)
  end

  private

  def find_user_blog_post
    @blog_post = current_user.blog_posts.find(params[:id])
  end

  def user_blog_post_params
    params.require(:user_blog_post).permit(secured_params.user_blog_post)
  end
end
