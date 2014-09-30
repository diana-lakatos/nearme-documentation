class Registrations::BlogController < ApplicationController
  before_filter :check_blog_enabled

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

  def blog_user
    @blog_user ||= User.find(params[:user_id]).decorate
  end

  def check_blog_enabled
    blog_user.blog.test_enabled
  end
end
