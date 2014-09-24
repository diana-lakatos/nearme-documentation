class UserBlog::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_blog_enabled?

  private

  def user_blog_enabled?
    redirect_to '/404' unless platform_context.instance.user_blogs_enabled?
  end
end
