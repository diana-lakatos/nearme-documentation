class Dashboard::UserBlog::BaseController < Dashboard::BaseController
  skip_before_filter :redirect_if_no_company, :redirect_unless_registration_completed
  before_filter :user_blog_enabled?
  before_filter :create_blog!

  private

  def create_blog!
    current_user.build_blog.save! unless current_user.blog.present?
  end

  def user_blog_enabled?
    unless platform_context.instance.blogging_enabled?(current_user)
      flash[:error] = t 'user_blog.errors.blogs_disabled'
      redirect_to dashboard_path
    end
  end
end
