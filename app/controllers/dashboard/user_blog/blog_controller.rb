class Dashboard::UserBlog::BlogController < Dashboard::UserBlog::BaseController
  before_filter :find_user_blog

  def show
    @user_blog_posts = UserBlogPostDecorator.decorate_collection(current_user.blog_posts.by_date
                                                                 .paginate(page: params[:page], per_page: 10))
  end

  def edit
    @blog = @blog.decorate
  end

  def update
    if @blog.update_attributes(user_blog_params)
      flash[:success] = t('flash_messages.user_blog.settings_saved')
      redirect_to edit_dashboard_blog_path
    else
      @blog = @blog.decorate
      render :edit
    end
  end

  def delete_image
    # We avoid interpolation because easy to go wrong and add security vulnerabilities
    case params[:image_type]
    when 'header_logo'
      @blog.remove_header_logo!
      @blog.save!
    when 'header_image'
      @blog.remove_header_image!
      @blog.save!
    when 'header_icon'
      @blog.remove_header_icon!
      @blog.save!
    end

    redirect_to edit_dashboard_blog_path
  end

  private

  def find_user_blog
    @blog = current_user.blog
  end

  def user_blog_params
    params.require(:user_blog).permit(secured_params.user_blog)
  end
end
