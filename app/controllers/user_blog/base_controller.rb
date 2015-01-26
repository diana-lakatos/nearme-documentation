class UserBlog::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_blog_enabled?
  before_filter :create_blog!

  private

  def create_blog!
    current_user.build_blog.save! unless current_user.blog.present?
  end

  def user_blog_enabled?
    redirect_to('/404', status: :not_found) unless platform_context.instance.user_blogs_enabled?
  end
end
