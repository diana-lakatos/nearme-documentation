class Registrations::BlogController < ApplicationController

  def index
    @user = blog_user
    @blog_posts = blog_user.blog_posts.by_date.published
  end

  def show
    @user = blog_user
    @blog_post = blog_user.blog_posts.published.find(params[:id])
  end

  def blog_user
    @blog_user ||= User.find(params[:user_id]).decorate
  end
end
