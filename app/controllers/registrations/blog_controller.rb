class Registrations::BlogController < ApplicationController
  before_filter :check_blog_enabled
  before_filter :set_theme

  def index
    @user = blog_user
    @blog_posts = UserBlogPostDecorator.decorate_collection(blog_user.published_blogs.paginate(page: params[:page]))

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @user = blog_user
    @blog_post = blog_user.published_blogs.find(params[:id]).decorate
  end

  private

  def set_theme
    @theme_name = 'user-blog'
  end

  def blog_user
    @blog_user ||= User.find(params[:user_id]).decorate
  end

  def check_blog_enabled
    if blog_user.blog.present? && !blog_user.blog.enabled? && blog_user == current_user
      redirect_to user_path(blog_user), notice: t('user_blog.errors.blog_disabled')
      return
    end

    blog_user.blog.test_enabled
  end
end
