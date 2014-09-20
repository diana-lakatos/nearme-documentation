class UserBlog::UserBlogController < ApplicationController

  before_filter :authenticate_user!

  def index
    @user_blog_posts = UserBlogPostDecorator.decorate_collection(current_user.blog_posts.by_date)
  end

  def settings
    @user_blog = current_user.blog.decorate
  end

  def update_settings
    @user_blog = current_user.blog
    if @user_blog.update_attributes(user_blog_params)
      flash[:success] = t('flash_messages.user_blog.settings_saved')
      redirect_to user_blog_path
    else
      @user_blog = @user_blog.decorate
      render :settings
    end
  end

  private

  def user_blog_params
    params.require(:user_blog).permit(secured_params.user_blog)
  end
end
