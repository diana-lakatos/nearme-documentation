class Registrations::BlogController < ApplicationController
  before_filter :check_blog_enabled

  def index
    @user = blog_user
    @blog_posts = blog_user.published_blogs
  end

  def show
    @user = blog_user
    @blog_post = blog_user.published_blogs.find(params[:id])
  end

  private

  def blog_user
    @blog_user ||= User.find(params[:user_id]).decorate
  end

  def check_blog_enabled
    blog_user.blog.test_enabled
  end
end
